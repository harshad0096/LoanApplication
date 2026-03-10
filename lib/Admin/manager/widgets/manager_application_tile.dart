import 'package:flutter/material.dart';
import '../models/manager_loan_model.dart';

class ManagerApplicationTile extends StatelessWidget {
  final ManagerLoanModel loan;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ManagerApplicationTile({
    super.key,
    required this.loan,
    required this.selected,
    required this.onTap,
    this.onApprove,
    this.onReject,
  });

  Color _statusColor() {
    switch (loan.status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    bool isMobile = width < 600;
    bool isTablet = width >= 600 && width < 1000;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffF1F5F9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xff6366F1) : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 3),
            )
          ],
        ),

        /// ============================
        /// MOBILE LAYOUT
        /// ============================
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topRow(),
                  const SizedBox(height: 10),
                  _loanInfo(),
                  const SizedBox(height: 12),
                  _actionButtons(),
                ],
              )

            /// ============================
            /// TABLET / DESKTOP
            /// ============================
            : Row(
                children: [
                  _avatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _nameSection(),
                  ),
                  Expanded(
                    child: _loanType(),
                  ),
                  Expanded(
                    child: _loanAmount(),
                  ),
                  Expanded(
                    child: _statusChip(),
                  ),
                  if (!isTablet) Expanded(child: _dateSection()),
                  const SizedBox(width: 10),
                  _actionButtons(),
                ],
              ),
      ),
    );
  }

  /// ============================
  /// USER AVATAR
  /// ============================
  Widget _avatar() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xff6366F1),
      child: Text(
        loan.name[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// ============================
  /// NAME + ID
  /// ============================
  Widget _nameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loan.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "ID: ${loan.id}",
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        )
      ],
    );
  }

  /// ============================
  /// LOAN TYPE
  /// ============================
  Widget _loanType() {
    return Text(
      loan.loanType,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// ============================
  /// LOAN AMOUNT
  /// ============================
  Widget _loanAmount() {
    return Text(
      "₹${loan.amount}",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// ============================
  /// STATUS CHIP
  /// ============================
  Widget _statusChip() {
    return Chip(
      label: Text(loan.status),
      backgroundColor: _statusColor().withOpacity(.15),
      labelStyle: TextStyle(
        color: _statusColor(),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// ============================
  /// DATE
  /// ============================
  Widget _dateSection() {
    return Text(
      loan.name,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );
  }

  /// ============================
  /// ACTION BUTTONS
  /// ============================
  Widget _actionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loan.status == "Pending") ...[
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: onApprove,
            tooltip: "Approve",
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: onReject,
            tooltip: "Reject",
          ),
        ],
        IconButton(
          icon: const Icon(Icons.visibility_outlined),
          onPressed: onTap,
          tooltip: "View Details",
        ),
      ],
    );
  }

  /// ============================
  /// MOBILE TOP ROW
  /// ============================
  Widget _topRow() {
    return Row(
      children: [
        _avatar(),
        const SizedBox(width: 12),
        Expanded(child: _nameSection()),
        _statusChip(),
      ],
    );
  }

  /// ============================
  /// MOBILE INFO
  /// ============================
  Widget _loanInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(loan.loanType),
        Text(
          "₹${loan.amount}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
