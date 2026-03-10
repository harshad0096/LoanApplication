import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

/// ===================== ENUMS =====================
enum UserRole { applicant, loanofficer, creditAnalyst, manager, admin }

enum UserStatus { active, inactive, blocked }

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
      return "Loan Officer";
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
      orElse: () => UserRole.applicant);
}

Color statusColor(UserStatus status) {
  switch (status) {
    case UserStatus.active:
      return Colors.green.shade100;
    case UserStatus.inactive:
      return Colors.grey.shade300;
    case UserStatus.blocked:
      return Colors.red.shade100;
  }
}

String statusLabel(UserStatus status) {
  switch (status) {
    case UserStatus.active:
      return "Active";
    case UserStatus.inactive:
      return "Inactive";
    case UserStatus.blocked:
      return "Blocked";
  }
}

/// ===================== PAGE =====================
class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  String search = "";
  String filterStatus = "All";

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
                    .update({'role': selectedRole.name});
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

  /// ================= CHANGE STATUS =================
  Future<void> _changeUserStatus(AppUser user, UserStatus newStatus) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .update({'status': newStatus.name});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${user.email} status updated")),
    );
  }

  /// ================= DELETE USER =================
  Future<void> _deleteUser(AppUser user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${user.email} deleted")),
    );
  }

  /// ================= CARD WIDGET =================
  Widget _statusCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value.toString(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text("User Management",
                style: GoogleFonts.inter(
                    fontSize: 26, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text("Manage and monitor all registered users",
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 20),

            /// FIRESTORE STREAM
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  UserStatus status;
                  if ((data['status'] ?? 'active') == 'active') {
                    status = UserStatus.active;
                  } else if ((data['status'] ?? '') == 'blocked') {
                    status = UserStatus.blocked;
                  } else {
                    status = UserStatus.inactive;
                  }

                  return AppUser(
                    id: doc.id,
                    name: data['name'] ?? data['email'],
                    email: data['email'] ?? '',
                    phone: data['phone'] ?? '',
                    role: roleFromString(data['role'] ?? 'applicant'),
                    status: status,
                    joined: (data['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                    lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                  );
                }).where((u) {
                  final matchesSearch =
                      u.name.toLowerCase().contains(search.toLowerCase()) ||
                          u.email.toLowerCase().contains(search.toLowerCase());
                  final matchesFilter = filterStatus == "All"
                      ? true
                      : statusLabel(u.status) == filterStatus;
                  return matchesSearch && matchesFilter;
                }).toList();

                // calculate totals
                final total = users.length;
                final activeCount =
                    users.where((u) => u.status == UserStatus.active).length;
                final blockedCount =
                    users.where((u) => u.status == UserStatus.blocked).length;

                return Expanded(
                  child: Column(
                    children: [
                      /// STATUS CARDS
                      Row(
                        children: [
                          _statusCard("Total Users", total, Icons.people,
                              Colors.purple),
                          const SizedBox(width: 12),
                          _statusCard("Active Users", activeCount, Icons.check,
                              Colors.green),
                          const SizedBox(width: 12),
                          _statusCard(
                              "Blocked", blockedCount, Icons.block, Colors.red),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// SEARCH + FILTERS
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: "Search by name or email...",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (v) => setState(() => search = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Wrap(
                            spacing: 8,
                            children: ["All", "Active", "Blocked", "Inactive"]
                                .map((f) => ChoiceChip(
                                      label: Text(f),
                                      selected: filterStatus == f,
                                      onSelected: (_) =>
                                          setState(() => filterStatus = f),
                                    ))
                                .toList(),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// USER TABLE
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth:
                                    screenWidth < 600 ? 600 : screenWidth),
                            child: DataTable(
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
                                    DataCell(Chip(
                                        label: Text(roleLabel(u.role)),
                                        backgroundColor:
                                            statusColor(u.status))),
                                    DataCell(Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 10,
                                          color: u.status == UserStatus.active
                                              ? Colors.green
                                              : u.status == UserStatus.blocked
                                                  ? Colors.red
                                                  : Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(statusLabel(u.status)),
                                      ],
                                    )),
                                    DataCell(Text(
                                        "${u.joined.day}/${u.joined.month}/${u.joined.year}")),
                                    DataCell(Text(
                                        "${u.lastLogin.day}/${u.lastLogin.month}/${u.lastLogin.year}")),
                                    DataCell(PopupMenuButton(
                                      itemBuilder: (_) => [
                                        PopupMenuItem(
                                          child: const Text("Change Role"),
                                          onTap: () => Future.delayed(
                                              Duration.zero,
                                              () => _changeUserRole(u)),
                                        ),
                                        PopupMenuItem(
                                          child: const Text(
                                            "Deactivate",
                                            style:
                                                TextStyle(color: Colors.orange),
                                          ),
                                          onTap: () => _changeUserStatus(
                                              u, UserStatus.inactive),
                                        ),
                                        PopupMenuItem(
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onTap: () => _deleteUser(u),
                                        ),
                                      ],
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
