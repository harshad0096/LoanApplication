import 'package:flutter/material.dart';

class DocumentModel {
  final String id;
  final String name;
  String status; // Pending, Verified, Rejected
  DateTime? verifiedOn;
  String? remarks;

  DocumentModel({
    required this.id,
    required this.name,
    this.status = 'Pending',
    this.verifiedOn,
    this.remarks,
  });
}

class LoanApplication {
  final String id;
  final String name;
  final String loanType;
  String status;
  final int credit;
  final String amount;
  final DateTime date;
  final int tenureMonths;
  final double interestRate;
  final List<DocumentModel> documents;

  LoanApplication({
    required this.id,
    required this.name,
    required this.loanType,
    required this.status,
    required this.credit,
    required this.amount,
    required this.date,
    this.tenureMonths = 36,
    this.interestRate = 12.5,
    this.documents = const [],
  });
}

// Reusable small statistic card (easy to edit)
Widget statCard({
  required IconData icon,
  required String title,
  required String value,
  required Color color,
}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    ),
  );
}

// Small selectable application item used in left column list
Widget applicationListItem(
  LoanApplication app, {
  required bool selected,
  required VoidCallback onTap,
}) {
  final total = app.documents.length;
  final verified = app.documents
      .where((d) => d.status.toLowerCase() == 'verified')
      .length;
  final pct = total == 0 ? 0 : ((verified / total) * 100).round();
  final daysSince = DateTime.now().difference(app.date).inDays;
  String priority = 'Low';
  if (daysSince <= 2) priority = 'High';
  if (daysSince > 2 && daysSince <= 7) priority = 'Medium';

  Color borderColor = selected ? Colors.blue.shade700 : Colors.grey.shade300;
  return InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
        color: selected ? Colors.blue.shade50 : Colors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(app.id, style: TextStyle(color: Colors.grey[500])),
                ],
              ),
              Column(
                children: [
                  _statusBadge(app.status),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(color: Colors.orange[800], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(app.loanType, style: TextStyle(color: Colors.grey[700])),
              const SizedBox(width: 12),
              Text(
                '• ${app.amount}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // progress
          if (total > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: verified / total,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(height: 6),
                Text(
                  'Verification Progress  $pct%',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

// Document row widget
Widget documentRow(DocumentModel doc, {required VoidCallback onReview}) {
  Color color = Colors.orange;
  if (doc.status.toLowerCase() == 'verified') color = Colors.green;
  if (doc.status.toLowerCase() == 'rejected') color = Colors.red;

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, size: 28, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(doc.status, style: TextStyle(color: color)),
                    ),
                    const SizedBox(width: 8),
                    if (doc.verifiedOn != null)
                      Text(
                        'Verified on ${doc.verifiedOn!.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(onPressed: onReview, child: const Text('Review')),
        ],
      ),
    ),
  );
}

Widget _statusBadge(String status) {
  Color color = Colors.orange;
  if (status.toLowerCase() == 'approved') color = Colors.green;
  if (status.toLowerCase() == 'rejected') color = Colors.red;
  if (status.toLowerCase() == 'manager review' ||
      status.toLowerCase() == 'under review')
    color = Colors.orange;

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(status, style: TextStyle(color: color)),
  );
}

// Show document verification dialog
Future<bool?> showDocumentVerificationDialog(
  BuildContext context,
  DocumentModel doc, {
  String? title,
}) {
  final TextEditingController remarksCtrl = TextEditingController(
    text: doc.remarks ?? '',
  );
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title ?? 'Verify Document'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.insert_drive_file,
                    size: 64,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Verification Checklist',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text('✓ Document is clearly visible'),
              const Text('✓ Name matches application'),
              const Text('✓ Document is not expired'),
              const Text('✓ No signs of tampering'),
              const SizedBox(height: 12),
              const Text(
                'Remarks (optional for approval, required for rejection)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: remarksCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add verification remarks...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Reject
              if (remarksCtrl.text.trim().isEmpty) {
                // require remarks for rejection
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please add remarks for rejection'),
                  ),
                );
                return;
              }
              doc.status = 'Rejected';
              doc.remarks = remarksCtrl.text.trim();
              Navigator.of(context).pop(false);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              // Verify
              doc.status = 'Verified';
              doc.verifiedOn = DateTime.now();
              doc.remarks = remarksCtrl.text.trim();
              Navigator.of(context).pop(true);
            },
            child: const Text('Verify'),
          ),
        ],
      );
    },
  );
}
