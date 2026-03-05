import 'package:flutter/material.dart';

class LoanOfficerVerificationsPage extends StatefulWidget {
  const LoanOfficerVerificationsPage({super.key});

  @override
  State<LoanOfficerVerificationsPage> createState() =>
      _LoanOfficerVerificationsPageState();
}

class _LoanOfficerVerificationsPageState
    extends State<LoanOfficerVerificationsPage> {
  int selectedIndex = 0;

  final applications = [
    {
      "name": "John Smith",
      "appId": "APP-2024-001",
      "loanType": "Personal",
      "amount": "₹500,000",
      "progress": 0.5,
      "priority": "High",
      "sla": "2024-01-18",
    },
    {
      "name": "Emily Davis",
      "appId": "APP-2024-002",
      "loanType": "Home",
      "amount": "₹2,500,000",
      "progress": 0.25,
      "priority": "Medium",
      "sla": "2024-01-20",
    },
    {
      "name": "Michael Chen",
      "appId": "APP-2024-003",
      "loanType": "Vehicle",
      "amount": "₹800,000",
      "progress": 0.0,
      "priority": "Low",
      "sla": "2024-01-22",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 900;
        final selected = applications[selectedIndex];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _statsRow(isMobile),
              const SizedBox(height: 16),
              Expanded(
                child: isMobile
                    ? _applicationsList(isMobile: true)
                    : Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _applicationsList(isMobile: false),
                          ),
                          const SizedBox(width: 16),
                          Expanded(flex: 3, child: _documentPanel(selected)),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= STATS =================
  Widget _statsRow(bool isMobile) {
    final stats = [
      const _StatCard("Pending Verifications", "3", Colors.orange),
      const _StatCard("Completed", "0", Colors.green),
      const _StatCard("High Priority", "1", Colors.red),
      const _StatCard("Total Documents", "11", Colors.blue),
    ];

    return isMobile
        ? SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => SizedBox(width: 220, child: stats[i]),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: stats.length,
            ),
          )
        : Row(children: stats);
  }

  // ================= APPLICATION LIST =================
  Widget _applicationsList({required bool isMobile}) {
    return ListView.builder(
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];

        return GestureDetector(
          onTap: () {
            setState(() => selectedIndex = index);

            if (isMobile) {
              _openMobileDetails(app);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedIndex == index
                    ? Colors.blue
                    : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      app["name"] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    _priorityChip(app["priority"] as String),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${app["loanType"] as String} • ${app["amount"] as String}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),

                /// ✅ MUST BE DOUBLE
                LinearProgressIndicator(
                  value: (app["progress"] as num).toDouble(),
                  minHeight: 6,
                ),

                const SizedBox(height: 6),
                Text(
                  "SLA Deadline: ${app["sla"] as String}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= DOCUMENT PANEL =================
  Widget _documentPanel(Map<String, dynamic> app) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Application ID: ${app["appId"]}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text("Loan Type: ${app["loanType"]}"),
            Text("Amount: ${app["amount"]}"),
            const Divider(height: 30),
            _docTile("Aadhaar Card", verified: true),
            _docTile("PAN Card", verified: true),
            _docTile("Salary Slip (3 months)"),
            _docTile("Bank Statement"),
          ],
        ),
      ),
    );
  }

  // ================= MOBILE BOTTOM SHEET =================
  void _openMobileDetails(Map<String, dynamic> app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: _documentPanel(app),
      ),
    );
  }

  // ================= DOCUMENT TILE =================
  Widget _docTile(String title, {bool verified = false}) {
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: Text(title),
      trailing: verified
          ? const Chip(label: Text("Verified"))
          : ElevatedButton(
              onPressed: () => _openVerifyDialog(title),
              child: const Text("Review"),
            ),
    );
  }

  void _openVerifyDialog(String docName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Verify Document"),
        content: Text("Verification checklist for $docName"),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Reject"),
          ),
          ElevatedButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  Widget _priorityChip(String priority) {
    Color color = Colors.grey;
    if (priority == "High") color = Colors.red;
    if (priority == "Medium") color = Colors.orange;

    return Chip(
      label: Text(priority),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
    );
  }
}

/// ================= STAT CARD =================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
