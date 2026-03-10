import 'package:cloud_firestore/cloud_firestore.dart';

class LoanApplicationModel {
  final String loanId;

  final String userId;
  final String userName;
  final String phone;

  final double amount;
  final int tenure;
  final String loanType;

  // Address
  final Map<String, dynamic> permanentAddress;
  final Map<String, dynamic> currentAddress;

  // Employment
  final String employmentType;
  final String employerName;
  final String employerAddress;
  final String workExperience;
  final String regNumber;
  final double monthlyIncome;

  // Bank
  final String bankName;
  final String accountNumber;
  final String ifsc;

  // Loan Status
  final String status;
  final String? adminRemark;
  final double? riskScore;

  final DateTime createdAt;
  final DateTime updatedAt;

  LoanApplicationModel({
    required this.loanId,
    required this.userId,
    required this.userName,
    required this.phone,
    required this.amount,
    required this.tenure,
    required this.loanType,
    required this.permanentAddress,
    required this.currentAddress,
    required this.employmentType,
    required this.employerName,
    required this.employerAddress,
    required this.workExperience,
    required this.regNumber,
    required this.monthlyIncome,
    required this.bankName,
    required this.accountNumber,
    required this.ifsc,
    required this.status,
    this.adminRemark,
    this.riskScore,
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
      "loanType": loanType,

      // Address
      "permanentAddress": permanentAddress,
      "currentAddress": currentAddress,

      // Employment
      "employmentType": employmentType,
      "employerName": employerName,
      "employerAddress": employerAddress,
      "workExperience": workExperience,
      "regNumber": regNumber,
      "monthlyIncome": monthlyIncome,

      // Bank
      "bankName": bankName,
      "accountNumber": accountNumber,
      "ifsc": ifsc,

      // Status
      "status": status,
      "adminRemark": adminRemark,
      "riskScore": riskScore,

      "createdAt": Timestamp.fromDate(createdAt),
      "updatedAt": Timestamp.fromDate(updatedAt),
    };
  }

  factory LoanApplicationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return LoanApplicationModel(
      loanId: doc.id,
      userId: data["userId"] ?? "",
      userName: data["userName"] ?? "",
      phone: data["phone"] ?? "",
      amount: (data["amount"] ?? 0).toDouble(),
      tenure: data["tenure"] ?? 0,
      loanType: data["loanType"] ?? "",
      permanentAddress:
          Map<String, dynamic>.from(data["permanentAddress"] ?? {}),
      currentAddress: Map<String, dynamic>.from(data["currentAddress"] ?? {}),
      employmentType: data["employmentType"] ?? "",
      employerName: data["employerName"] ?? "",
      employerAddress: data["employerAddress"] ?? "",
      workExperience: data["workExperience"] ?? "",
      regNumber: data["regNumber"] ?? "",
      monthlyIncome: (data["monthlyIncome"] ?? 0).toDouble(),
      bankName: data["bankName"] ?? "",
      accountNumber: data["accountNumber"] ?? "",
      ifsc: data["ifsc"] ?? "",
      status: data["status"] ?? "SUBMITTED",
      adminRemark: data["adminRemark"],
      riskScore: (data["riskScore"] ?? 0).toDouble(),
      createdAt: (data["createdAt"] is Timestamp)
          ? (data["createdAt"] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: (data["updatedAt"] is Timestamp)
          ? (data["updatedAt"] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
