import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // ================= SEND NOTIFICATION =================
  // Call this function whenever you want to push a new notification
  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': title,
      'body': body,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text("User not logged in"));
    }

    // ================= REAL-TIME FIRESTORE STREAM =================
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ref.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No notifications yet"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              return _notificationTile(data);
            },
          );
        },
      ),
    );
  }

  // ================= NOTIFICATION TILE =================
  Widget _notificationTile(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final isRead = data['isRead'] ?? false;
    final title = data['title'] ?? '';
    final body = data['body'] ?? '';
    final time = data['createdAt'] as Timestamp?;
    final formattedTime =
        time != null ? DateFormat('dd MMM, hh:mm a').format(time.toDate()) : '';

    return GestureDetector(
      onTap: () => _markAsRead(doc),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xffEEF2FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? Colors.grey.shade200 : const Color(0xff6366F1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isRead ? Icons.notifications_none : Icons.notifications,
              color: const Color(0xff6366F1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(body),
                  const SizedBox(height: 6),
                  Text(formattedTime,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xff6366F1),
                  shape: BoxShape.circle,
                ),
              )
          ],
        ),
      ),
    );
  }

  // ================= MARK NOTIFICATION AS READ =================
  Future<void> _markAsRead(QueryDocumentSnapshot doc) async {
    await doc.reference.update({'isRead': true});
  }
}
