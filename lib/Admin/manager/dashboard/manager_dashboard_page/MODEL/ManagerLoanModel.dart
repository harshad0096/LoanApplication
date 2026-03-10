import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerLoanModel {
  String id;
  String name;
  String loanType;
  String amount;
  String status;
  String officerRemark;

  ManagerLoanModel({
    required this.id,
    required this.name,
    required this.loanType,
    required this.amount,
    required this.status,
    required this.officerRemark,
  });

  factory ManagerLoanModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ManagerLoanModel(
      id: doc.id,
      name: data['userName'] ?? "No Name",
      loanType: data['loanType'] ?? "",
      amount: "₹${data['amount'] ?? 0}",
      status: data['status'] ?? "MANAGER_APPROVAL",
      officerRemark: data['loanOfficerRemark'] ?? "",
    );
  }
}
