import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerUsersPage extends StatefulWidget {
  const ManagerUsersPage({super.key});

  @override
  State<ManagerUsersPage> createState() => _ManagerUsersPageState();
}

class _ManagerUsersPageState extends State<ManagerUsersPage> {
  final searchCtrl = TextEditingController();

  Stream<QuerySnapshot> usersStream() {
    return FirebaseFirestore.instance.collection("users").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    bool isMobile = width < 700;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            const Text(
              "Users Management",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Manage customers and system users",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// SEARCH BAR
            TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),

            /// USERS LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: usersStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final users = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data["name"] ?? "").toLowerCase();
                    final email = (data["email"] ?? "").toLowerCase();
                    final search = searchCtrl.text.toLowerCase();

                    return name.contains(search) || email.contains(search);
                  }).toList();

                  if (users.isEmpty) {
                    return const Center(
                      child: Text("No users found"),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: isMobile ? 3.2 : 3,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final data = users[index].data() as Map<String, dynamic>;

                      return _userCard(
                        users[index].id,
                        data["name"] ?? "",
                        data["email"] ?? "",
                        data["role"] ?? "User",
                        data["status"] ?? "ACTIVE",
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// USER CARD
  Widget _userCard(
      String id, String name, String email, String role, String status) {
    Color statusColor = status == "ACTIVE" ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(.05),
          )
        ],
      ),
      child: Row(
        children: [
          /// AVATAR
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xff6366F1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "U",
              style: const TextStyle(color: Colors.white),
            ),
          ),

          const SizedBox(width: 14),

          /// USER INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    /// ROLE CHIP
                    Chip(
                      label: Text(role),
                      backgroundColor: Colors.blue.withOpacity(.12),
                      labelStyle: const TextStyle(color: Colors.blue),
                    ),

                    const SizedBox(width: 8),

                    /// STATUS CHIP
                    Chip(
                      label: Text(status),
                      backgroundColor: statusColor.withOpacity(.15),
                      labelStyle: TextStyle(color: statusColor),
                    ),
                  ],
                )
              ],
            ),
          ),

          /// ACTION BUTTON
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "view",
                child: Text("View Profile"),
              ),
              const PopupMenuItem(
                value: "block",
                child: Text("Block User"),
              ),
              const PopupMenuItem(
                value: "delete",
                child: Text("Delete User"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
