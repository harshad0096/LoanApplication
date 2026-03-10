import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loan_application_model.dart';

class LoanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =====================================================
  // FETCH POLICY BY LOAN TYPE
  // =====================================================
  Future<Map<String, dynamic>> _getLoanPolicy(String loanType) async {
    final doc =
        await _firestore.collection('loan_policies').doc(loanType).get();

    if (!doc.exists) {
      throw Exception("Loan policy not found for $loanType");
    }

    return doc.data()!;
  }

  String generateLoanId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "LN$timestamp";
  }

  // =====================================================
  // CREATE LOAN WITH AUTO POLICY APPLY
  // =====================================================
  Future<void> createLoan(LoanApplicationModel loan) async {
    final policyRef = _firestore.collection('loan_policies').doc(loan.loanType);

    final applicationRef =
        _firestore.collection('loan_applications').doc(loan.loanId);

    final logRef = _firestore.collection('loan_status_logs').doc();

    await _firestore.runTransaction((transaction) async {
      final policySnap = await transaction.get(policyRef);

      if (!policySnap.exists) {
        throw Exception("Loan policy not found");
      }

      final policy = policySnap.data()!;

      final double interest = (policy['interest'] ?? 0).toDouble();
      final double feePercent = (policy['processingFee'] ?? 0).toDouble();

      final double monthlyRate = interest / 100 / 12;

      final emi =
          (loan.amount * monthlyRate * pow(1 + monthlyRate, loan.tenure)) /
              (pow(1 + monthlyRate, loan.tenure) - 1);

      final processingFee = (loan.amount * feePercent) / 100;

      transaction.set(applicationRef, {
        ...loan.toMap(),
        "interestRate": interest,
        "emi": emi,
        "processingFeePercent": feePercent,
        "processingFeeAmount": processingFee,
        "status": "SUBMITTED",
        "currentStage": "DOC_PENDING",
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      transaction.set(logRef, {
        "loanId": loan.loanId,
        "status": "SUBMITTED",
        "role": "USER",
        "changedBy": loan.userId,
        "remark": "Loan submitted",
        "timestamp": FieldValue.serverTimestamp(),
      });
    });
  }

  // =====================================================
  // ADMIN APPROVE
  // =====================================================
  Future<void> approveLoan({
    required String loanId,
    required String remark,
  }) async {
    await _firestore.collection('loan_applications').doc(loanId).update({
      "status": "APPROVED",
      "adminRemark": remark,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  // =====================================================
  // ADMIN REJECT
  // =====================================================
  Future<void> rejectLoan({
    required String loanId,
    required String remark,
  }) async {
    await _firestore.collection('loan_applications').doc(loanId).update({
      "status": "REJECTED",
      "adminRemark": remark,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  // =====================================================
  // GET ALL LOANS (ADMIN)
  // =====================================================
  Stream<List<LoanApplicationModel>> getAllLoans() {
    return _firestore
        .collection('loan_applications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LoanApplicationModel.fromDoc(doc))
            .toList());
  }

  // =====================================================
  // GET USER LOANS
  // =====================================================
  Stream<List<LoanApplicationModel>> getUserLoans(String userId) {
    return _firestore
        .collection('loan_applications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LoanApplicationModel.fromDoc(doc))
            .toList());
  }
}
