import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

    final uid = FirebaseAuth.instance.currentUser?.uid;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.3,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      titleSpacing: 12,
      title: Row(
        children: [
          /// ☰ MENU
          if (isMobile)
            IconButton(
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu, color: Colors.black),
            ),

          /// 🔷 Logo
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
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

          /// 🏷 Title
          if (!isVerySmall)
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "QuickLoan",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
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

          /// 🟢 STATUS
          if (isTablet)
            const Row(
              children: [
                Icon(Icons.circle, color: Colors.green, size: 9),
                SizedBox(width: 6),
                Text(
                  "All systems operational",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                SizedBox(width: 12),
              ],
            ),

          /// 🔔 NOTIFICATION BADGE
          if (uid != null)
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
                            color: const Color(0xffEF4444),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            count > 99 ? '99+' : count.toString(),
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
            )
          else
            const Icon(Icons.notifications_outlined),

          /// ⚙ Settings
          if (!isVerySmall)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings_outlined),
            ),

          const SizedBox(width: 6),

          /// 👤 FIREBASE PROFILE (UPDATED)
          if (uid != null)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String name = "User";
                String? photoUrl;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  name = data["name"] ?? "User";
                  photoUrl = data["photoUrl"];
                }

                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserProfilePage(),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
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
                          radius: 11,
                          backgroundColor: Colors.purple,
                          backgroundImage:
                              (photoUrl != null && photoUrl.isNotEmpty)
                                  ? NetworkImage(photoUrl)
                                  : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
                              ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : "U",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 9),
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
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
