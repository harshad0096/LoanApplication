import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PayEmisPage extends StatefulWidget {
  const PayEmisPage({super.key});

  @override
  State<PayEmisPage> createState() => _PayEmisPageState();
}

class _PayEmisPageState extends State<PayEmisPage> {
  bool showSchedule = false;

  final Color primary = const Color(0xff6366F1);
  final Color gradient2 = const Color(0xffD946EF);

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 900;
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > 600 &&
      MediaQuery.of(context).size.width <= 900;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (isDesktop(context)) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildLeftSection()),
                      const SizedBox(width: 20),
                      Expanded(flex: 1, child: _buildRightSection()),
                    ],
                  );
                } else if (isTablet(context)) {
                  return Column(
                    children: [
                      _buildLeftSection(),
                      const SizedBox(height: 20),
                      _buildRightSection(),
                    ],
                  );
                } else {
                  // Mobile: scrollable
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildLeftSection(),
                        const SizedBox(height: 20),
                        _buildRightSection(),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  /// LEFT SECTION
  Widget _buildLeftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pay EMI",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          "Manage and pay your loan EMIs or close your loan early",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        _loanSelector(),
        const SizedBox(height: 24),
        _statsRow(),
        const SizedBox(height: 24),
        _repaymentCard(),
        const SizedBox(height: 20),
        _emiSchedule(),
      ],
    );
  }

  /// LOAN SELECTOR
  Widget _loanSelector() {
    return Row(
      children: [
        Expanded(
          child: _loanTile(
            title: "Personal Loan",
            amount: "₹250,000",
            selected: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _loanTile(
            title: "Car Loan",
            amount: "₹500,000",
          ),
        ),
      ],
    );
  }

  Widget _loanTile(
      {required String title, required String amount, bool selected = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? Colors.white : const Color(0xffF0F1F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: selected ? primary : Colors.transparent, width: 2),
        boxShadow: selected
            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
            : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primary, gradient2]),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.account_balance_wallet, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(amount, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  /// STATS ROW
  Widget _statsRow() {
    return Row(
      children: [
        Expanded(child: _statCard("Loan Amount", "₹2.5L")),
        const SizedBox(width: 12),
        Expanded(child: _statCard("EMIs Paid", "14/24")),
        const SizedBox(width: 12),
        Expanded(child: _statCard("Remaining", "10 EMIs")),
        const SizedBox(width: 12),
        Expanded(child: _statCard("Outstanding", "₹117K")),
      ],
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  /// REPAYMENT CARD
  Widget _repaymentCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 70,
            lineWidth: 12,
            percent: 0.58,
            center: const Text("58%",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            circularStrokeCap: CircularStrokeCap.round,
            linearGradient: LinearGradient(colors: [primary, gradient2]),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Personal Loan Repayment",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Disbursed on 15 Jan 2023 • 10.5% p.a."),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Text("Total Paid "),
                    SizedBox(width: 6),
                    Text("₹163,100",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                    Spacer(),
                    Text("Amount Left "),
                    SizedBox(width: 6),
                    Text("₹116,500",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const LinearProgressIndicator(value: 0.58),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// EMI SCHEDULE
  Widget _emiSchedule() {
    final months = [
      "Apr 2026",
      "May 2026",
      "Jun 2026",
      "Jul 2026",
      "Aug 2026",
      "Sep 2026"
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => showSchedule = !showSchedule),
          child: Row(
            children: [
              Icon(Icons.calendar_month, color: primary),
              const SizedBox(width: 8),
              Text(
                  showSchedule
                      ? "Hide Upcoming EMI Schedule"
                      : "View Upcoming EMI Schedule",
                  style: TextStyle(color: primary)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (showSchedule)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: months
                  .map((m) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(m),
                        subtitle: const Text("₹11,650"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xffEEF2FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(m == "Apr 2026" ? "Next Due" : "Upcoming",
                              style: TextStyle(color: primary)),
                        ),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  /// RIGHT SECTION
  Widget _buildRightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _paymentOptions(),
        const SizedBox(height: 16),
        _paymentSummary(),
        const SizedBox(height: 16),
        _payButton(),
      ],
    );
  }

  Widget _paymentOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text("Pay Monthly EMI"),
            trailing:
                Text("₹11,650", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text("Pay Total & Close"),
            trailing: Text("₹117K"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.currency_rupee),
            title: Text("Custom Amount"),
          ),
        ],
      ),
    );
  }

  Widget _paymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Payment Summary",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Text("Loan : Personal Loan"),
          Text("Loan ID : LN001"),
          Text("Debit From : HDFC Bank ****4521"),
          Text("Payment Type : Monthly EMI"),
          SizedBox(height: 8),
          Text("Total Payable ₹11,650",
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff6366F1),
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _payButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, gradient2]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Center(
        child: Text(
          "Pay ₹11,650",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
