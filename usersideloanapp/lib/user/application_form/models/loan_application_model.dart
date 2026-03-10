import 'package:cloud_firestore/cloud_firestore.dart';

class LoanApplicationModel {
  final String loanId;
  final String userId;
  final String userName;
  final String phone;

  final double amount;
  final int tenure;
  final String purpose;
  final String loanType;

  final String employerName;
  final String employerAddress;
  final String workExperience;

  final String bankName;
  final String accountNumber;
  final String ifsc;

  final String status; // SUBMITTED / APPROVED / REJECTED
  final String? adminRemark;

  final DateTime createdAt;
  final DateTime updatedAt;

  LoanApplicationModel({
    required this.loanId,
    required this.userId,
    required this.userName,
    required this.phone,
    required this.amount,
    required this.tenure,
    required this.purpose,
    required this.loanType,
    required this.employerName,
    required this.employerAddress,
    required this.workExperience,
    required this.bankName,
    required this.accountNumber,
    required this.ifsc,
    required this.status,
    this.adminRemark,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "loanId": loanId,
      "userId": userId,
      "userName": userName,
      "phone": phone,
      "amount": amount,
      "tenure": tenure,
      "purpose": purpose,
      "loanType": loanType,
      "employerName": employerName,
      "employerAddress": employerAddress,
      "workExperience": workExperience,
      "bankName": bankName,
      "accountNumber": accountNumber,
      "ifsc": ifsc,
      "status": status,
      "adminRemark": adminRemark,
      "createdAt": Timestamp.fromDate(createdAt),
      "updatedAt": Timestamp.fromDate(updatedAt),
    };
  }

  factory LoanApplicationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LoanApplicationModel(
      loanId: doc.id,
      userId: data["userId"] ?? "",
      userName: data["userName"] ?? "",
      phone: data["phone"] ?? "",
      amount: (data["amount"] ?? 0).toDouble(),
      tenure: data["tenure"] ?? 0,
      purpose: data["purpose"] ?? "",
      loanType: data["loanType"] ?? "",
      employerName: data["employerName"] ?? "",
      employerAddress: data["employerAddress"] ?? "",
      workExperience: data["workExperience"] ?? "",
      bankName: data["bankName"] ?? "",
      accountNumber: data["accountNumber"] ?? "",
      ifsc: data["ifsc"] ?? "",
      status: data["status"] ?? "SUBMITTED",
      adminRemark: data["adminRemark"],
      createdAt: (data["createdAt"] as Timestamp).toDate(),
      updatedAt: (data["updatedAt"] as Timestamp).toDate(),
    );
  }
}
