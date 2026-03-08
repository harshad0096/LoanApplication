import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usersideloanapp/Login/Login.dart';

import 'package:usersideloanapp/user/UserDashboard/UserProfilePage.dart';

class QuickLoanAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final bool isMobile;
  final VoidCallback? onNotificationTap;

  const QuickLoanAppBar({
    super.key,
    this.onMenuTap,
    required this.isMobile,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isVerySmall = width < 380;
    final isTablet = width >= 700;

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      titleSpacing: 12,
      title: Row(
        children: [
          /// ☰ MENU
          if (isMobile)
            IconButton(
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu, color: Colors.black),
            ),

          /// LOGO
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff7B61FF), Color(0xffA855F7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.currency_rupee, color: Colors.white, size: 20),
          ),

          const SizedBox(width: 10),

          /// TITLE
          if (!isVerySmall)
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "QuickLoan",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  "FINANCE PORTAL",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),

          const Spacer(),

          /// SYSTEM STATUS
          if (isTablet)
            const Row(
              children: [
                Icon(Icons.circle, color: Colors.green, size: 9),
                SizedBox(width: 6),
                Text(
                  "All systems operational",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                SizedBox(width: 16),
              ],
            ),

          /// =====================
          /// USER NOT LOGGED IN
          /// =====================
          if (uid == null) ...[
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(initialRoute: ''),
                  ),
                );
              },
              child: const Text(
                "Login",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7F00FF),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(initialRoute: ''),
                  ),
                );
              },
              child: const Text("Get Started"),
            ),
          ],

          /// =====================
          /// USER LOGGED IN
          /// =====================
          if (uid != null) ...[
            /// NOTIFICATION
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('notifications')
                  .where('isRead', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                int count = 0;
                if (snapshot.hasData) {
                  count = snapshot.data!.docs.length;
                }

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: onNotificationTap,
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            count > 99 ? "99+" : count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            /// SETTINGS
            if (!isVerySmall)
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),

            const SizedBox(width: 6),

            /// USER PROFILE
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String name = "User";
                String? photo;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  name = data["name"] ?? "User";
                  photo = data["photoUrl"];
                }

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserProfilePage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isVerySmall ? 6 : 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.purple,
                          backgroundImage: (photo != null && photo.isNotEmpty)
                              ? NetworkImage(photo)
                              : null,
                          child: (photo == null || photo.isEmpty)
                              ? Text(
                                  name[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10),
                                )
                              : null,
                        ),
                        if (!isVerySmall) const SizedBox(width: 6),
                        if (!isVerySmall)
                          Text(
                            name,
                            style: const TextStyle(fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
