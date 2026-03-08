import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usersideloanapp/user/layouts/loan_flow_shell.dart';
import '../providers/loan_provider.dart';

class LoanStep2Purpose extends StatefulWidget {
  const LoanStep2Purpose({super.key});

  @override
  State<LoanStep2Purpose> createState() => _LoanStep2PurposeState();
}

class _LoanStep2PurposeState extends State<LoanStep2Purpose> {
  final _formKey = GlobalKey<FormState>();

  final purposeController = TextEditingController();

  // Permanent
  final pAddressController = TextEditingController();
  final pCityController = TextEditingController();
  final pStateController = TextEditingController();
  final pCountryController = TextEditingController();
  final pAreaController = TextEditingController();
  final pPinController = TextEditingController();
  final pLandmarkController = TextEditingController();

  // Current
  final cAddressController = TextEditingController();
  final cCityController = TextEditingController();
  final cStateController = TextEditingController();
  final cCountryController = TextEditingController();
  final cAreaController = TextEditingController();
  final cPinController = TextEditingController();
  final cLandmarkController = TextEditingController();

  bool sameAddress = false;

  void copyAddress() {
    if (sameAddress) {
      cAddressController.text = pAddressController.text;
      cCityController.text = pCityController.text;
      cStateController.text = pStateController.text;
      cCountryController.text = pCountryController.text;
      cAreaController.text = pAreaController.text;
      cPinController.text = pPinController.text;
      cLandmarkController.text = pLandmarkController.text;
    }
  }

  Widget textField(
      String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? "Required field" : null,
      ),
    );
  }

  Widget sectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoanFlowShell(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text("Loan Application"),
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// PURPOSE CARD
                    sectionCard(
                      "Loan Purpose",
                      Icons.account_balance_wallet,
                      [
                        textField(
                          "Purpose of Loan",
                          purposeController,
                          Icons.edit,
                        )
                      ],
                    ),

                    /// PERMANENT ADDRESS
                    sectionCard(
                      "Permanent Address",
                      Icons.home,
                      [
                        textField(
                            "Address", pAddressController, Icons.location_on),
                        textField("Area", pAreaController, Icons.map),
                        textField("City", pCityController, Icons.location_city),
                        textField("State", pStateController, Icons.flag),
                        textField("Country", pCountryController, Icons.public),
                        textField("PIN Code", pPinController, Icons.pin),
                        textField("Landmark", pLandmarkController, Icons.place),
                      ],
                    ),

                    /// SAME ADDRESS SWITCH
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Checkbox(
                            value: sameAddress,
                            onChanged: (v) {
                              setState(() {
                                sameAddress = v!;
                                copyAddress();
                              });
                            },
                          ),
                          const Text(
                            "Current address same as permanent",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),

                    /// CURRENT ADDRESS
                    sectionCard(
                      "Current Address",
                      Icons.location_history,
                      [
                        textField(
                            "Address", cAddressController, Icons.location_on),
                        textField("Area", cAreaController, Icons.map),
                        textField("City", cCityController, Icons.location_city),
                        textField("State", cStateController, Icons.flag),
                        textField("Country", cCountryController, Icons.public),
                        textField("PIN Code", cPinController, Icons.pin),
                        textField("Landmark", cLandmarkController, Icons.place),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// CONTINUE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;

                          context
                              .read<LoanProvider>()
                              .setPurpose(purposeController.text.trim());

                          Navigator.pushNamed(context, '/loan-step3');
                        },
                        child: const Text(
                          "Continue",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30)
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
