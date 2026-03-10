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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loan.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Text("Loan Type: ${loan.loanType}"),
          Text("Amount: ${loan.amount}"),
          Text("Tenure: ${loan.tenure} months"),
          Text("Interest: ${loan.interestRate}%"),

          const SizedBox(height: 20),

          /// OFFICER REMARK
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Officer Remark: ${loan.officerRemark}",
            ),
          ),

          const SizedBox(height: 20),

          /// MANAGER REMARK
          TextField(
            controller: controller.remarkCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Manager Remark",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              ElevatedButton(
                onPressed: controller.approveLoan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Approve Loan"),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: controller.rejectLoan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("Reject Loan"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
