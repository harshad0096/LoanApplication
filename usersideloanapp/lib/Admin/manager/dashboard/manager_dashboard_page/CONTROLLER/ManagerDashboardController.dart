import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usersideloanapp/Admin/manager/dashboard/manager_dashboard_page/MODEL/ManagerLoanModel.dart';

class ManagerDashboardController extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  RxList<ManagerLoanModel> loanList = <ManagerLoanModel>[].obs;

  Rx<ManagerLoanModel?> selectedLoan = Rx<ManagerLoanModel?>(null);

  TextEditingController remarkCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadLoans();
  }

  /// ==========================
  /// FIREBASE LISTENER
  /// ==========================

  void loadLoans() {
    db
        .collection('loan_applications')
        .where("status", isEqualTo: "MANAGER_APPROVAL")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) {
      loanList.value =
          snapshot.docs.map((doc) => ManagerLoanModel.fromDoc(doc)).toList();
    });
  }

  /// ==========================
  /// APPROVE
  /// ==========================

  Future approveLoan() async {
    if (selectedLoan.value == null) return;

    await db
        .collection("loan_applications")
        .doc(selectedLoan.value!.id)
        .update({
      "status": "APPROVED",
      "managerRemark": remarkCtrl.text,
      "reviewedBy": "Manager",
      "reviewedAt": FieldValue.serverTimestamp(),
    });

    remarkCtrl.clear();
  }

  /// ==========================
  /// REJECT
  /// ==========================

  Future rejectLoan() async {
    if (selectedLoan.value == null) return;

    await db
        .collection("loan_applications")
        .doc(selectedLoan.value!.id)
        .update({
      "status": "REJECTED",
      "managerRemark": remarkCtrl.text,
      "reviewedBy": "Manager",
      "reviewedAt": FieldValue.serverTimestamp(),
    });

    remarkCtrl.clear();
  }
}
