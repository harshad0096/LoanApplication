import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loan_application_model.dart';

class LoanOfficerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<LoanApplication> applications = <LoanApplication>[].obs;
  Rx<LoanApplication?> selectedApp = Rx<LoanApplication?>(null);
  RxBool loading = false.obs;

  @override
  void onInit() {
    fetchApplications();
    super.onInit();
  }

  void fetchApplications() async {
    loading.value = true;

    final snapshot = await _firestore.collection("loan_applications").get();

    applications.value =
        snapshot.docs.map((e) => LoanApplication.fromFirestore(e)).toList();

    if (applications.isNotEmpty) {
      selectedApp.value = applications.first;
    }

    loading.value = false;
  }

  void selectApplication(LoanApplication app) {
    selectedApp.value = app;
  }

  Future<void> changeStatus(String id, String status) async {
    await _firestore
        .collection("loan_applications")
        .doc(id)
        .update({"status": status});

    fetchApplications();
  }
}
