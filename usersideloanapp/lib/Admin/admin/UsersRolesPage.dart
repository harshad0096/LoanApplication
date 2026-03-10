import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ===================== ENUMS =====================
enum UserRole { applicant, loanofficer, creditAnalyst, manager, admin }

enum UserStatus { active, inactive }

/// ===================== MODEL =====================
class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  UserRole role;
  UserStatus status;
  final DateTime joined;
  DateTime lastLogin;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.joined,
    required this.lastLogin,
  });
}

/// ===================== HELPERS =====================
String roleLabel(UserRole role) {
  switch (role) {
    case UserRole.applicant:
      return "Applicant";
    case UserRole.loanofficer:
      return "loanofficer";
    case UserRole.creditAnalyst:
      return "Credit Analyst";
    case UserRole.manager:
      return "Manager";
    case UserRole.admin:
      return "Admin";
  }
}

UserRole roleFromString(String role) {
  return UserRole.values.firstWhere(
    (e) => e.name.toLowerCase() == role.toLowerCase(),
    orElse: () => UserRole.applicant,
  );
}

String roleToString(UserRole role) => role.name.toLowerCase();
Color roleColor(UserRole role) {
  switch (role) {
    case UserRole.applicant:
      return Colors.blue.shade100;
    case UserRole.loanofficer:
      return Colors.teal.shade100;
    case UserRole.creditAnalyst:
      return Colors.orange.shade100;
    case UserRole.manager:
      return Colors.green.shade100;
    case UserRole.admin:
      return Colors.grey.shade300;
  }
}

/// ===================== PAGE =====================
class UsersRolesPage extends StatefulWidget {
  const UsersRolesPage({super.key});

  @override
  State<UsersRolesPage> createState() => _UsersRolesPageState();
}

class _UsersRolesPageState extends State<UsersRolesPage> {
  String search = "";

  /// ================= CHANGE ROLE =================
  Future<void> _changeUserRole(AppUser user) async {
    UserRole selectedRole = user.role;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change User Role"),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return DropdownButton<UserRole>(
                value: selectedRole,
                isExpanded: true,
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(roleLabel(role)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedRole = value);
                  }
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.id)
                    .update({'role': roleToString(selectedRole)});

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Role updated successfully")),
                );
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  /// ================= DEACTIVATE =================
  Future<void> _deactivateUser(AppUser user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).update({
      'status': 'inactive',
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("User deactivated")));
  }

  /// ================= DELETE =================
  Future<void> _deleteUser(AppUser user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).delete();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("User deleted")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Users & Roles",
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Manage system users and their permissions",
              style: GoogleFonts.inter(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            /// SEARCH + ADD BUTTON
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search by email...",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => search = v),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text("Add User"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// FIRESTORE STREAM
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs
                      .map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        return AppUser(
                          id: doc.id,
                          name: data['email'] ?? '',
                          email: data['email'] ?? '',
                          phone: data['phone'] ?? '',
                          role: roleFromString(data['role'] ?? 'applicant'),
                          status: data['status'] == 'inactive'
                              ? UserStatus.inactive
                              : UserStatus.active,
                          joined: (data['createdAt'] as Timestamp?)?.toDate() ??
                              DateTime.now(),
                          lastLogin:
                              (data['lastLogin'] as Timestamp?)?.toDate() ??
                                  DateTime.now(),
                        );
                      })
                      .where(
                        (u) => u.email.toLowerCase().contains(
                              search.toLowerCase(),
                            ),
                      )
                      .toList();

                  if (users.isEmpty) {
                    return const Center(child: Text("No users found"));
                  }

                  return Card(
                    elevation: 2,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text("User")),
                          DataColumn(label: Text("Contact")),
                          DataColumn(label: Text("Role")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Joined")),
                          DataColumn(label: Text("Last Login")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: users.map((u) {
                          return DataRow(
                            cells: [
                              DataCell(Text(u.name)),
                              DataCell(Text("${u.email}\n${u.phone}")),
                              DataCell(
                                Chip(
                                  label: Text(roleLabel(u.role)),
                                  backgroundColor: roleColor(u.role),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: u.status == UserStatus.active
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(u.status.name),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  "${u.joined.day}/${u.joined.month}/${u.joined.year}",
                                ),
                              ),
                              DataCell(
                                Text(
                                  "${u.lastLogin.day}/${u.lastLogin.month}/${u.lastLogin.year}",
                                ),
                              ),
                              DataCell(
                                PopupMenuButton(
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      child: const Text("Change Role"),
                                      onTap: () => Future.delayed(
                                        Duration.zero,
                                        () => _changeUserRole(u),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      child: const Text(
                                        "Deactivate",
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                      onTap: () => _deactivateUser(u),
                                    ),
                                    PopupMenuItem(
                                      child: const Text(
                                        "Delete User",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onTap: () => _deleteUser(u),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
