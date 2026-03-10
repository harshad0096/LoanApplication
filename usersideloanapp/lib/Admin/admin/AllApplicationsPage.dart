import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllApplicationsPage extends StatefulWidget {
  const AllApplicationsPage({super.key});

  @override
  State<AllApplicationsPage> createState() => _AllApplicationsPageState();
}

class _AllApplicationsPageState extends State<AllApplicationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f8fb),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('All Applications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('loan_applications') // ✅ FIXED HERE
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No Applications Found"));
            }

            final docs = snapshot.data!.docs;

            final filteredDocs = selectedStatus == 'All'
                ? docs
                : docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['status'] == selectedStatus;
                  }).toList();

            return Column(
              children: [
                _buildSummaryCards(docs),
                const SizedBox(height: 20),
                Expanded(child: _buildTable(filteredDocs)),
              ],
            );
          },
        ),
      ),
    );
  }

  /* ========================
     SUMMARY CARDS
  ======================== */

  Widget _buildSummaryCards(List<QueryDocumentSnapshot> docs) {
    int approved = docs.where((d) => d['status'] == 'APPROVED').length;
    int rejected = docs.where((d) => d['status'] == 'REJECTED').length;
    int pending = docs.where((d) => d['status'] == 'PENDING').length;

    return Row(
      children: [
        _card('Total', docs.length, Colors.blue),
        _card('Pending', pending, Colors.orange),
        _card('Approved', approved, Colors.green),
        _card('Rejected', rejected, Colors.red),
      ],
    );
  }

  Widget _card(String title, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  /* ========================
     TABLE
  ======================== */

  Widget _buildTable(List<QueryDocumentSnapshot> docs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Applicant')),
            DataColumn(label: Text('Loan Type')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Admin Remark')),
            DataColumn(label: Text('Actions')),
          ],
          rows: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return DataRow(cells: [
              DataCell(Text(doc.id)),
              DataCell(Text(data['userName'] ?? '')),
              DataCell(Text(data['loanType'] ?? '')),
              DataCell(Text('₹${data['amount'] ?? 0}')),
              DataCell(_statusChip(data['status'] ?? '')),
              DataCell(Text(data['adminRemark'] ?? '')),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _updateStatus(doc.id, 'APPROVED'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _showRejectDialog(doc.id),
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  /* ========================
     UPDATE STATUS
  ======================== */

  Future<void> _updateStatus(String docId, String status,
      {String remark = ''}) async {
    // 1️⃣ Get the loan document to fetch userId and loan info
    final docSnapshot =
        await _firestore.collection('loan_applications').doc(docId).get();

    if (!docSnapshot.exists) return;

    final data = docSnapshot.data() as Map<String, dynamic>;
    final userId = data['userId'] as String?;
    final loanType = data['loanType'] ?? "Loan";
    final loanAmount = (data['loanAmount'] ?? 0).toDouble();

    // 2️⃣ Update the loan status in Firestore
    await _firestore.collection('loan_applications').doc(docId).update({
      'status': status,
      'adminRemark': remark,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 3️⃣ Send a notification to the user
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': "Loan $status",
        'body':
            "$loanType of ₹${loanAmount.toStringAsFixed(0)} has been $status. ${remark.isNotEmpty ? 'Remark: $remark' : ''}",
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // 4️⃣ Show feedback to admin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Application $status')),
    );
  }

  /* ========================
     REJECT DIALOG
  ======================== */

  void _showRejectDialog(String docId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Application'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter rejection remark',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateStatus(
                docId,
                'REJECTED',
                remark: controller.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  /* ========================
     STATUS CHIP
  ======================== */

  Widget _statusChip(String status) {
    Color color;

    switch (status) {
      case 'APPROVED':
        color = Colors.green;
        break;
      case 'REJECTED':
        color = Colors.red;
        break;
      case 'PENDING':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(.1),
      labelStyle: TextStyle(color: color),
    );
  }
}
