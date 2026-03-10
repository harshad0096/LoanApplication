import 'package:flutter/material.dart';
import 'package:usersideloanapp/Admin/manager/dashboard/manager_dashboard_page/CONTROLLER/ManagerDashboardController.dart';
import '../models/manager_loan_model.dart';

class ManagerDetailPanel extends StatelessWidget {
  final ManagerLoanModel loan;
  final ManagerDashboardController controller;

  const ManagerDetailPanel({
    super.key,
    required this.loan,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    bool isMobile = width < 700;

    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xffF8FAFC),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            _header(),

            const SizedBox(height: 24),

            /// LOAN SUMMARY
            _summaryCards(isMobile),

            const SizedBox(height: 24),

            isMobile
                ? Column(
                    children: [
                      _loanDetailsCard(),
                      const SizedBox(height: 20),
                      _remarksSection(),
                      const SizedBox(height: 20),
                      _actionButtons(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _loanDetailsCard(),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _remarksSection(),
                            const SizedBox(height: 20),
                            _actionButtons(),
                          ],
                        ),
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }

  /// ================================
  /// HEADER
  /// ================================
  Widget _header() {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xff6366F1),
          child: Text(
            loan.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loan.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Application ID: ${loan.id}",
              style: const TextStyle(
                color: Colors.grey,
              ),
            )
          ],
        )
      ],
    );
  }

  /// ================================
  /// SUMMARY CARDS
  /// ================================
  Widget _summaryCards(bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.4,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _statCard("Loan Amount", "₹${loan.amount}", Icons.account_balance),
        _statCard("Loan Type", loan.loanType, Icons.description),
        _statCard("Tenure", "${loan.tenure} Months", Icons.schedule),
        _statCard("Interest", "${loan.interestRate}%", Icons.trending_up),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff6366F1)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  /// ================================
  /// LOAN DETAILS CARD
  /// ================================
  Widget _loanDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Loan Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          _detailRow("Loan Type", loan.loanType),
          _detailRow("Amount", "₹${loan.amount}"),
          _detailRow("Tenure", "${loan.tenure} months"),
          _detailRow("Interest Rate", "${loan.interestRate}%"),
          const SizedBox(height: 20),
          const Text(
            "Loan Officer Remark",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(loan.officerRemark),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// ================================
  /// REMARK SECTION
  /// ================================
  Widget _remarksSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Manager Remark",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller.remarkCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Add approval / rejection remark",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  /// ================================
  /// ACTION BUTTONS
  /// ================================
  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text("Approve Loan"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: controller.approveLoan,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.close),
            label: const Text("Reject Loan"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: controller.rejectLoan,
          ),
        ),
      ],
    );
  }
}
