import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usersideloanapp/user/application_form/models/loan_application_model.dart';

class LoanProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= LOADING =================

  bool isLoading = false;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // ================= LOAN DETAILS =================

  String loanType = "";
  double amount = 100000;
  int tenure = 24;

  // ================= POLICY =================

  double interestRate = 12;
  double minAmount = 10000;
  double maxAmount = 500000;

  bool policyLoaded = false;

  // ================= ADDRESS =================

  Map<String, String> permanentAddress = {
    "address": "",
    "area": "",
    "city": "",
    "state": "",
    "country": "",
    "pin": "",
    "landmark": "",
  };

  Map<String, String> currentAddress = {
    "address": "",
    "area": "",
    "city": "",
    "state": "",
    "country": "",
    "pin": "",
    "landmark": "",
  };

  // ================= EMPLOYMENT =================

  String employmentType = "Salaried";
  String employerName = "";
  String employerAddress = "";
  String workExperience = "";
  String regNumber = "";
  double monthlyIncome = 25000.0;

  // ================= BANK =================

  String bankName = "";
  String accountNumber = "";
  String ifsc = "";

  // =================================================
  // SETTERS
  // =================================================

  void setLoanType(String type) {
    loanType = type;
    notifyListeners();
  }

  void setBasicDetails({
    required double amount,
    required int tenure,
  }) {
    this.amount = amount;
    this.tenure = tenure;
    notifyListeners();
  }

  void setAmount(double value) {
    amount = value;
    notifyListeners();
  }

  void setTenure(int value) {
    tenure = value;
    notifyListeners();
  }

  /// ADDRESS SETTERS
  ///
  ///
  ///

// In LoanProvider.dart

// Add this to your class
  void setAddresses({
    required Map<String, String> permanent,
    required Map<String, String> current,
  }) {
    permanentAddress = permanent;
    currentAddress = current;
    notifyListeners();
  }

  bool get isAddressValid {
    bool check(Map<String, String> addr) {
      return (addr["address"] ?? "").isNotEmpty &&
          (addr["city"] ?? "").isNotEmpty &&
          (addr["pin"] ?? "").isNotEmpty &&
          (addr["state"] ?? "").isNotEmpty;
    }

    bool isValid = check(permanentAddress) && check(currentAddress);

    if (!isValid) {
      debugPrint(
          "Address Validation Failed! Perm: $permanentAddress | Curr: $currentAddress");
    }
    return isValid;
  }

  void setPermanentAddress(Map<String, String> address) {
    permanentAddress = address;
    notifyListeners();
  }

  void setCurrentAddress(Map<String, String> address) {
    currentAddress = address;
    notifyListeners();
  }

  /// EMPLOYMENT
  void setEmployment({
    required String employerName,
    required String employerAddress,
    required String workExperience,
    required String type,
    required double income,
    required String regNo,
  }) {
    this.employerName = employerName;
    this.employerAddress = employerAddress;
    this.workExperience = workExperience;
    this.employmentType = type;
    this.monthlyIncome = income;
    this.regNumber = regNo;
    notifyListeners();
  }

  /// BANK
  void setBank({
    required String bankName,
    required String accountNumber,
    required String ifsc,
  }) {
    this.bankName = bankName;
    this.accountNumber = accountNumber;
    this.ifsc = ifsc;
    notifyListeners();
  }

  // =================================================
  // EMI CALCULATION
  // =================================================

  double get emi {
    final monthlyRate = interestRate / 100 / 12;

    final emiValue = (amount * monthlyRate * pow(1 + monthlyRate, tenure)) /
        (pow(1 + monthlyRate, tenure) - 1);

    return emiValue.isFinite ? emiValue : 0;
  }

  // =================================================
  // ELIGIBILITY SCORE
  // =================================================

  double get eligibilityScore {
    double score = 0.5;

    if (amount < 500000) score += 0.2;
    if (tenure <= 24) score += 0.2;
    if (workExperience.isNotEmpty) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  // =================================================
  // VALIDATIONS
  // =================================================

  bool get isLoanValid {
    return loanType.isNotEmpty && amount >= minAmount && amount <= maxAmount;
  }

  bool get isEmploymentValid {
    return employerName.isNotEmpty &&
        employerAddress.isNotEmpty &&
        workExperience.isNotEmpty;
  }

  bool get isBankValid {
    return bankName.isNotEmpty && accountNumber.length >= 8 && ifsc.length >= 8;
  }

  bool get isApplicationValid {
    return isLoanValid && isAddressValid && isEmploymentValid && isBankValid;
  }

  // =================================================
  // FETCH LOAN POLICY
  // =================================================

  Future<void> fetchPolicy() async {
    if (policyLoaded) return;

    try {
      final snapshot =
          await _firestore.collection('loanPolicies').limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        interestRate = (data['interest'] ?? 12).toDouble();
        minAmount = (data['minAmount'] ?? 10000).toDouble();
        maxAmount = (data['maxAmount'] ?? 500000).toDouble();

        policyLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Policy fetch error: $e");
    }
  }

  // =================================================
  // SUBMIT LOAN APPLICATION
  // =================================================

  Future<String> submitLoanApplication({
    required String userId,
    required String userName,
    required String phone,
  }) async {
    if (!isApplicationValid) {
      print("Loan Valid: $isLoanValid");
      print("Address Valid: $isAddressValid");
      print("Employment Valid: $isEmploymentValid");
      print("Bank Valid: $isBankValid");
      throw Exception("Loan form incomplete.");
    }

    setLoading(true);

    try {
      final loanRef = _firestore.collection("loan_applications").doc();

      final model = LoanApplicationModel(
        loanId: loanRef.id,
        userId: userId,
        userName: userName,
        phone: phone,
        amount: amount,
        tenure: tenure,
        loanType: loanType,
        permanentAddress: permanentAddress,
        currentAddress: currentAddress,
        employmentType: employmentType,
        employerName: employerName,
        employerAddress: employerAddress,
        workExperience: workExperience,
        regNumber: regNumber,
        monthlyIncome: monthlyIncome,
        bankName: bankName,
        accountNumber: accountNumber,
        ifsc: ifsc,
        status: "SUBMITTED",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await loanRef.set({
        ...model.toMap(),
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      return loanRef.id;
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // =================================================
  // RESET
  // =================================================

  void reset() {
    loanType = "";
    amount = 100000;
    tenure = 24;

    permanentAddress.updateAll((key, value) => "");
    currentAddress.updateAll((key, value) => "");

    employerName = "";
    employerAddress = "";
    workExperience = "";
    regNumber = "";
    monthlyIncome = 25000.0;

    bankName = "";
    accountNumber = "";
    ifsc = "";

    isLoading = false;

    notifyListeners();
  }
}
