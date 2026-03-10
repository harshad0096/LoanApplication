import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final user = FirebaseAuth.instance.currentUser;

  // Helper for Responsive Layout
  bool isWide(BuildContext context) => MediaQuery.of(context).size.width > 800;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('loan_applications')
          .where('userId', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final loans = snapshot.data!.docs;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatsGrid(loans),

              const SizedBox(height: 24),
              cibilScoreCard(750), // Example CIBIL score card
              const SizedBox(height: 24),
              // Replace your Row inside build() with this:
              LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  // Desktop View: Side by side
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: _buildQuickActions(context)),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildLoansSection(loans)),
                    ],
                  );
                } else {
                  // Mobile View: Stacked
                  return Column(
                    children: [
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      _buildLoansSection(loans),
                    ],
                  );
                }
              }),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xff6366F1), Color(0xffD946EF)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Good Morning, welcome back 👋",
              style: TextStyle(color: Colors.white70)),
          const Text("Rahul Kumar",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              "Your financial dashboard is ready. You have a pre-approved offer waiting!",
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {}, child: const Text("Apply Now →")),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white)),
                child: const Text("Track Status",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatsGrid(List<QueryDocumentSnapshot> loans) {
    // Mocking logic for example
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: isWide(context) ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _statItem("₹7,50,000", "Total Loans", "+12%"),
        _statItem("₹5,430/mo", "Active EMIs", "24 months left"),
        _statItem("₹5,00,000", "Credit Limit", "60% utilized"),
        _statItem("2,450 pts", "Reward Points", "+180 this month"),
      ],
    );
  }

  Widget _statItem(String val, String label, String sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(val,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(sub, style: const TextStyle(color: Colors.green, fontSize: 12)),
        ],
      ),
    );
  }

  Widget cibilScoreCard(int score) {
    // Normalize score between 300 and 900
    double percent = ((score - 300) / (900 - 300)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("CIBIL Score",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: const Text("Excellent",
                    style: TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const Text("Updated 2 hours ago",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          Center(
            child: CircularPercentIndicator(
              radius: 70.0,
              lineWidth: 12.0,
              percent: percent,
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: Colors.grey.shade200,
              linearGradient: const LinearGradient(
                colors: [Colors.redAccent, Colors.orange, Colors.green],
              ),
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("$score",
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold)),
                  const Text("Good",
                      style: TextStyle(
                          color: Colors.teal, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("⚡ +12 points this month",
                  style: TextStyle(color: Colors.teal)),
              Text("Full Report >",
                  style: TextStyle(
                      color: Colors.indigo, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLoansSection(List<QueryDocumentSnapshot> loans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Your Loans",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("View All ↗",
                style: TextStyle(
                    color: Colors.indigo, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        ...loans.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Logic for progress: Assuming 'paidAmount' and 'amount' fields exist
          double totalAmount = (data['amount'] ?? 0).toDouble();
          double paidAmount = (data['paidAmount'] ?? 0).toDouble();
          double progress = totalAmount > 0
              ? (paidAmount / totalAmount).clamp(0.0, 1.0)
              : 0.0;
          bool isCompleted = progress >= 1.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['loanType'] ?? "Loan",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.grey.shade100
                            : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isCompleted ? "✓ Completed" : "● Active",
                        style: TextStyle(
                            color: isCompleted ? Colors.grey : Colors.teal,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("₹${data['amount']}",
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Repayment Progress",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("${(progress * 100).toInt()}%",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? Colors.purple : Colors.purpleAccent),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        "title": "Apply for Loan",
        "sub": "Get instant approval",
        "icon": Icons.credit_card,
        "color": Colors.indigo,
        "route": "/loan-step1"
      },
      {
        "title": "Track Status",
        "sub": "View your applications",
        "icon": Icons.trending_up,
        "color": Colors.teal,
        "route": "/home"
      },
      {
        "title": "Upload Documents",
        "sub": "Upload & manage",
        "icon": Icons.upload_file,
        "color": Colors.orange,
        "route": "/upload-document"
      },
      {
        "title": "Notifications",
        "sub": "Stay updated",
        "icon": Icons.notifications_none,
        "color": Colors.green,
        "route": "/home"
      },
    ];

    return LayoutBuilder(builder: (context, constraints) {
      // 4 columns on desktop, 2 on mobile
      int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.2, // Adjusted for the vertical icon-top layout
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final item = actions[index];
          return _ActionCard(item: item);
        },
      );
    });
  }
}

class _ActionCard extends StatefulWidget {
  final Map<String, dynamic> item;
  const _ActionCard({required this.item});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isHovered ? widget.item['color'] : Colors.grey.shade200),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                      color: widget.item['color'].withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ]
              : [],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (widget.item['route'] == '/upload-document') {
              Get.toNamed(widget.item['route'], arguments: 'loan_id_here');
            } else {
              Get.toNamed(widget.item['route']);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.item['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(widget.item['icon'],
                      color: widget.item['color'], size: 28),
                ),
                const SizedBox(height: 16),
                Text(widget.item['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(widget.item['sub'],
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
