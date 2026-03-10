import 'package:cloud_firestore/cloud_firestore.dart';

class LoanApplication {
  String id;
  String name;
  String loanType;
  String status;
  int credit;
  String amount;
  DateTime date;
  int tenureMonths;
  double interestRate;
  List<DocumentModel> documents;

  LoanApplication({
    required this.id,
    required this.name,
    required this.loanType,
    required this.status,
    required this.credit,
    required this.amount,
    required this.date,
    required this.tenureMonths,
    required this.interestRate,
    required this.documents,
  });

  factory LoanApplication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LoanApplication(
      id: doc.id,
      name: data['name'] ?? '',
      loanType: data['loanType'] ?? '',
      status: data['status'] ?? 'Submitted',
      credit: data['creditScore'] ?? 0,
      amount: data['amount'] ?? '0',
      date: (data['date'] as Timestamp).toDate(),
      tenureMonths: data['tenureMonths'] ?? 0,
      interestRate: (data['interestRate'] ?? 0).toDouble(),
      documents: [],
    );
  }
}

class DocumentModel {
  String name;
  String status;

  DocumentModel({
    required this.name,
    required this.status,
  });
}
