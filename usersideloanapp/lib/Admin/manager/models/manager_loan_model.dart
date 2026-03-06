import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerLoanModel {
  final String id;
  final String name;
  final String loanType;
  final String status;
  final String amount;
  final int tenure;
  final double interestRate;
  final String officerRemark;

  ManagerLoanModel({
    required this.id,
    required this.name,
    required this.loanType,
    required this.status,
    required this.amount,
    required this.tenure,
    required this.interestRate,
    required this.officerRemark,
  });

  factory ManagerLoanModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ManagerLoanModel(
      id: doc.id,
      name: data['userName'] ?? '',
      loanType: data['loanType'] ?? '',
      status: data['status'] ?? 'PENDING',
      amount: "₹${data['amount'] ?? 0}",
      tenure: data['tenure'] ?? 12,
      interestRate: (data['interestRate'] ?? 10).toDouble(),
      officerRemark: data['loanOfficerRemark'] ?? '',
    );
  }
}
