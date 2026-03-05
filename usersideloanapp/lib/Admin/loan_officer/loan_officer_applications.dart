import 'package:flutter/material.dart';

class LoanOfficerApplicationsPage extends StatefulWidget {
  const LoanOfficerApplicationsPage({super.key});

  @override
  State<LoanOfficerApplicationsPage> createState() =>
      _LoanOfficerApplicationsPageState();
}

class _LoanOfficerApplicationsPageState
    extends State<LoanOfficerApplicationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int selectedIndex = 0;

  final List<Map<String, dynamic>> applications = [
    {
      "name": "John Smith",
      "id": "LA001",
      "loanType": "Personal Loan",
      "amount": "₹5,00,000",
      "tenure": "36 months",
      "interest": "12.5% p.a.",
      "emi": "₹16,743",
      "status": "Under Review",
      "date": "15 Jan 2024",
    },
    {
      "name": "John Smith",
      "id": "LA002",
      "loanType": "Home Loan",
      "amount": "₹35,00,000",
      "tenure": "240 months",
      "interest": "8.5% p.a.",
      "emi": "₹30,125",
      "status": "Approved",
      "date": "10 Jan 2024",
    },
    {
      "name": "Alice Brown",
      "id": "LA003",
      "loanType": "Education Loan",
      "amount": "₹8,00,000",
      "tenure": "60 months",
      "interest": "10.2% p.a.",
      "emi": "₹17,042",
      "status": "Manager Review",
      "date": "18 Jan 2024",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final app = applications[selectedIndex];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          /// LEFT PANEL
          SizedBox(width: 360, child: _applicationList()),
          const SizedBox(width: 16),

          /// RIGHT PANEL
          Expanded(child: _applicationDetails(app)),
        ],
      ),
    );
  }

  // ================= LEFT LIST =================
  Widget _applicationList() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search applications...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  return GestureDetector(
                    onTap: () => setState(() => selectedIndex = index),
                    child: _applicationTile(
                      app,
                      active: selectedIndex == index,
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

  Widget _applicationTile(Map<String, dynamic> app, {bool active = false}) {
    Color color = _statusColor(app["status"]);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: active ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: active ? Border.all(color: Colors.blue) : null,
      ),
      child: ListTile(
        title: Text(
          app["name"],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(app["id"]),
            const SizedBox(height: 4),
            Text("${app["loanType"]} • ${app["amount"]}"),
          ],
        ),
        trailing: Chip(
          label: Text(app["status"]),
          backgroundColor: color.withOpacity(.15),
          labelStyle: TextStyle(color: color),
        ),
      ),
    );
  }

  // ================= RIGHT DETAILS =================
  Widget _applicationDetails(Map<String, dynamic> app) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app["name"],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("${app["id"]} • Applied on ${app["date"]}"),
                  ],
                ),
                Row(
                  children: [
                    _actionButton("Approve", Icons.check, Colors.green, () {
                      _updateStatus("Approved");
                    }),
                    const SizedBox(width: 8),
                    _actionButton("Hold", Icons.pause, Colors.orange, () {
                      _updateStatus("On Hold");
                    }),
                    const SizedBox(width: 8),
                    _actionButton("Reject", Icons.close, Colors.red, () {
                      _updateStatus("Rejected");
                    }),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: "Loan Details"),
                Tab(text: "Applicant Info"),
                Tab(text: "Documents"),
                Tab(text: "Eligibility"),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _loanDetailsTab(app),
                  const Center(child: Text("Applicant Info UI")),
                  const Center(child: Text("Documents UI")),
                  const Center(child: Text("Eligibility Rules UI")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loanDetailsTab(Map<String, dynamic> app) {
    return ListView(
      children: [
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _infoCard("Loan Type", app["loanType"]),
            _infoCard("Amount", app["amount"]),
            _infoCard("Tenure", app["tenure"]),
            _infoCard("Interest Rate", app["interest"]),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Monthly EMI",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                app["emi"],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= HELPERS =================
  void _updateStatus(String status) {
    setState(() {
      applications[selectedIndex]["status"] = status;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Status updated to $status")));
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      case "On Hold":
        return Colors.orange;
      case "Under Review":
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
