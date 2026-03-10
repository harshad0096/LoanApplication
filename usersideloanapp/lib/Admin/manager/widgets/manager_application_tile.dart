import 'package:flutter/material.dart';
import '../models/manager_loan_model.dart';

class ManagerApplicationTile extends StatelessWidget {
  final ManagerLoanModel loan;
  final bool selected;
  final VoidCallback onTap;

  const ManagerApplicationTile({
    super.key,
    required this.loan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(loan.name),
      subtitle: Text(loan.loanType),
      trailing: const Chip(
        label: Text("Manager Approval"),
        backgroundColor: Color(0xffE3F2FD),
      ),
      selected: selected,
      onTap: onTap,
    );
  }
}
