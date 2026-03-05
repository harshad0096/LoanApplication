import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoanProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // ================= LOAN =================
  String loanType = "";
  double amount = 100000;
  int tenure = 24;
  String purpose = "";

  // ================= EMPLOYMENT =================
  String employerName = "";
  String employerAddress = "";
  String workExperience = "";

  // ================= BANK =================
  String bankName = "";
  String accountNumber = "";
  String ifsc = "";

  // ================= SETTERS =================
  void setBasicDetails({
    required double amount,
    required int tenure,
  }) {
    this.amount = amount;
    this.tenure = tenure;
    notifyListeners();
  }

  void setLoanType(String type) {
    loanType = type;
    notifyListeners();
  }

  void setAmount(double val) {
    amount = val;
    notifyListeners();
  }

  void setTenure(int val) {
    tenure = val;
    notifyListeners();
  }

  void setPurpose(String val) {
    purpose = val;
    notifyListeners();
  }

  // ✅ FIXED EMPLOYMENT METHOD
  void setEmployment({
    required String employerName,
    required String employerAddress,
    required String workExperience,
  }) {
    this.employerName = employerName;
    this.employerAddress = employerAddress;
    this.workExperience = workExperience;
    notifyListeners();
  }

  void setBank({
    required String bank,
    required String acc,
    required String ifscCode,
    required String accountNumber,
    required String ifsc,
    required String bankName,
  }) {
    bankName = bank;
    accountNumber = acc;
    ifsc = ifscCode;
    notifyListeners();
  }

  // ================= EMI =================
  double get emi {
    const rate = 0.12 / 12;
    final months = tenure;

    if (rate == 0) return amount / months;

    final emiValue = (amount * rate * (months)) / ((months) - 1);

    return emiValue.isFinite ? emiValue : 0;
  }

  // ================= ELIGIBILITY =================
  double get eligibilityScore {
    double score = 0.5;

    if (amount < 500000) score += 0.2;
    if (tenure <= 24) score += 0.2;

    return score.clamp(0.0, 1.0);
  }

  // ================= RESET =================
  void reset() {
    loanType = "";
    amount = 100000;
    tenure = 24;
    purpose = "";
    employerName = "";
    employerAddress = "";
    workExperience = "";
    bankName = "";
    accountNumber = "";
    ifsc = "";
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchPolicy() async {
    try {
      final snapshot = await _firestore.collection('loanPolicies').get();
      // Convert documents to a list of maps
      final policies = snapshot.docs.map((doc) => doc.data()).toList();
      return policies;
    } catch (e) {
      print('Error fetching policies: $e');
      return [];
    }
  }
}
