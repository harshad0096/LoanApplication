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

  // =====================================================
  // CREATE LOAN WITH AUTO POLICY APPLY
  // =====================================================
  Future<void> createLoan(LoanApplicationModel loan) async {
    final policyRef = _firestore.collection('loan_policies').doc(loan.loanType);

    final applicationRef =
        _firestore.collection('loan_applications').doc(loan.loanId);

    await _firestore.runTransaction((transaction) async {
      final policySnap = await transaction.get(policyRef);

      if (!policySnap.exists) {
        throw Exception("Loan policy not found");
      }

      final policy = policySnap.data()!;

      final double interest = (policy['interest'] ?? 0).toDouble();
      final int minAmount = policy['minAmount'] ?? 0;
      final int maxAmount = policy['maxAmount'] ?? 0;
      final int minTenure = policy['minTenure'] ?? 0;
      final int maxTenure = policy['maxTenure'] ?? 0;
      final double processingFee = (policy['processingFee'] ?? 0).toDouble();

      // ================= VALIDATION =================
      if (loan.amount < minAmount || loan.amount > maxAmount) {
        throw Exception("Amount must be between ₹$minAmount - ₹$maxAmount");
      }

      if (loan.tenure < minTenure || loan.tenure > maxTenure) {
        throw Exception(
            "Tenure must be between $minTenure - $maxTenure months");
      }

      // ================= EMI CALCULATION =================
      final double monthlyRate = interest / 12 / 100;
      final int months = loan.tenure;

      final double emi =
          (loan.amount * monthlyRate * (pow(1 + monthlyRate, months))) /
              (pow(1 + monthlyRate, months) - 1);

      final double processingFeeAmount = (loan.amount * processingFee) / 100;

      // ================= SAVE =================
      transaction.set(applicationRef, {
        ...loan.toMap(),
        "interestRate": interest,
        "emi": emi,
        "processingFeePercent": processingFee,
        "processingFeeAmount": processingFeeAmount,
        "status": "PENDING",
        "policySnapshot": policy,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
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
