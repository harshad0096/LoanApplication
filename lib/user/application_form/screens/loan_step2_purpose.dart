import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:usersideloanapp/user/application_form/providers/loan_provider.dart';
import 'package:usersideloanapp/user/layouts/loan_flow_shell.dart';

class LoanStep2Purpose extends StatefulWidget {
  const LoanStep2Purpose({super.key});

  @override
  State<LoanStep2Purpose> createState() => _LoanStep2PurposeState();
}

class _LoanStep2PurposeState extends State<LoanStep2Purpose> {
  final _formKey = GlobalKey<FormState>();

  final pAddressController = TextEditingController();
  final pPinController = TextEditingController();
  final pCityController = TextEditingController();

  final cAddressController = TextEditingController();
  final cPinController = TextEditingController();
  final cCityController = TextEditingController();

  bool sameAddress = false;
  bool isVerifying = false;
  List<String> pCities = [];
  List<String> cCities = [];

  String? pSelectedCity;
  String? cSelectedCity;
  String? sState, csState;

  /// PIN API Cache
  final Map<String, Map<String, String>> pinCache = {};

  final List<String> indiaStates = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Delhi",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Tamil Nadu",
    "Telangana",
    "Uttar Pradesh",
    "West Bengal"
  ];

  @override
  void dispose() {
    pAddressController.dispose();
    pPinController.dispose();
    pCityController.dispose();
    cAddressController.dispose();
    cPinController.dispose();
    cCityController.dispose();
    super.dispose();
  }

  void _syncAddress() {
    if (sameAddress) {
      cAddressController.text = pAddressController.text;
      cPinController.text = pPinController.text;

      cSelectedCity = pSelectedCity; // FIX
      csState = sState;

      setState(() {});
    }
  }

  /// Fetch City + State from PIN
  Future<void> _fetchAddressFromPin(String pin,
      {bool isPermanent = true}) async {
    if (pin.length != 6) return;

    try {
      final res = await http
          .get(Uri.parse("https://api.postalpincode.in/pincode/$pin"));

      final data = json.decode(res.body);

      if (data[0]["Status"] == "Success") {
        final List offices = data[0]["PostOffice"];

        List<String> cities =
            offices.map<String>((e) => e["Name"].toString()).toSet().toList();

        String state = offices[0]["State"];

        setState(() {
          if (isPermanent) {
            sState = state;
            pCities = cities;
            pSelectedCity = cities.first;
          } else {
            csState = state;
            cCities = cities;
            cSelectedCity = cities.first;
          }
        });
      } else {
        _showSnack("Invalid PIN Code");
      }
    } catch (e) {
      debugPrint("PIN API Error: $e");
      _showSnack("Unable to fetch address");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return LoanFlowShell(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FA),
        appBar: AppBar(
            title: const Text("Location Details",
                style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0),
        body: AnimationLimiter(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 400),
                  childAnimationBuilder: (w) => SlideAnimation(
                      verticalOffset: 30, child: FadeInAnimation(child: w)),
                  children: [
                    /// Permanent Address
                    _buildSectionCard(
                        "Permanent Address", Icons.home_outlined, [
                      _buildTextField("Flat / Street", pAddressController,
                          Icons.location_on),
                      _buildTextField(
                          "PIN Code", pPinController, Icons.pin_drop,
                          isNum: true, onChanged: (v) {
                        if (v.length == 6) _fetchAddressFromPin(v);
                      }),
                      _buildDropDown("State", indiaStates, sState,
                          (v) => setState(() => sState = v)),
                      _buildDropDown(
                        "City",
                        pCities,
                        pSelectedCity,
                        (v) => setState(() => pSelectedCity = v),
                      ),
                    ]),

                    /// Same Address Checkbox
                    CheckboxListTile(
                      title: const Text("Same as Permanent"),
                      value: sameAddress,
                      onChanged: (v) => setState(() {
                        sameAddress = v!;
                        if (sameAddress) _syncAddress();
                      }),
                    ),

                    /// Current Address
                    Opacity(
                      opacity: sameAddress ? 0.6 : 1,
                      child: _buildSectionCard(
                          "Current Address", Icons.mail_outline, [
                        _buildTextField("Flat / Street", cAddressController,
                            Icons.location_on,
                            enabled: !sameAddress),
                        _buildDropDown("State", indiaStates, csState,
                            (v) => setState(() => csState = v),
                            enabled: !sameAddress),
                        _buildDropDown(
                          "City",
                          cCities,
                          cSelectedCity,
                          (v) => setState(() => cSelectedCity = v),
                          enabled: !sameAddress,
                        ),
                        _buildTextField(
                            "PIN Code", cPinController, Icons.pin_drop,
                            isNum: true, enabled: !sameAddress, onChanged: (v) {
                          if (v.length == 6)
                            _fetchAddressFromPin(v, isPermanent: false);
                        }),
                      ]),
                    ),

                    _buildContinueButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section Card UI
  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
                blurRadius: 10, color: Colors.black12, offset: Offset(0, 4))
          ]),
      child: Column(
        children: [
          Row(children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
          ]),
          const Divider(height: 30),
          ...children
        ],
      ),
    );
  }

  /// TextField
  Widget _buildTextField(
      String label, TextEditingController ctrl, IconData icon,
      {bool enabled = true, bool isNum = false, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        enabled: enabled,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
        decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: enabled ? const Color(0xFFF9FAFB) : Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none)),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  /// Searchable Dropdown
  Widget _buildDropDown(String label, List<String> items, String? selected,
      Function(String?) onChanged,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownSearch<String>(
        enabled: enabled,
        items: (f, p) => items,
        selectedItem: selected,
        onChanged: onChanged,
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Search state...",
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
              labelText: label,
              prefixIcon: const Icon(Icons.map),
              filled: true,
              fillColor:
                  enabled ? const Color(0xFFF9FAFB) : Colors.grey.shade100,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none)),
        ),
      ),
    );
  }

  /// Continue Button
  // In LoanStep2Purpose.dart - replace your existing _buildContinueButton

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
        ),
        onPressed: isVerifying
            ? null
            : () async {
                if (!_formKey.currentState!.validate()) {
                  _showSnack("Please fill all required fields");
                  return;
                }

                if (pSelectedCity == null || sState == null) {
                  _showSnack("Please select Permanent city and state");
                  return;
                }

                if (!sameAddress &&
                    (cSelectedCity == null || csState == null)) {
                  _showSnack("Please select Current city and state");
                  return;
                }

                setState(() => isVerifying = true);

                final loanProvider =
                    Provider.of<LoanProvider>(context, listen: false);

                final pData = {
                  "address": pAddressController.text.trim(),
                  "area": "",
                  "city": pSelectedCity!,
                  "state": sState!,
                  "country": "India",
                  "pin": pPinController.text.trim(),
                  "landmark": "",
                };

                final cData = sameAddress
                    ? {
                        "address": pAddressController.text.trim(),
                        "area": "",
                        "city": pSelectedCity!,
                        "state": sState!,
                        "country": "India",
                        "pin": pPinController.text.trim(),
                        "landmark": "",
                      }
                    : {
                        "address": cAddressController.text.trim(),
                        "area": "",
                        "city": cSelectedCity!,
                        "state": csState!,
                        "country": "India",
                        "pin": cPinController.text.trim(),
                        "landmark": "",
                      };
                loanProvider.setAddresses(
                  permanent: pData,
                  current: cData,
                );

                await Future.delayed(const Duration(milliseconds: 300));

                if (mounted) {
                  Navigator.pushNamed(context, '/loan-step3');
                }

                setState(() => isVerifying = false);
              },
        child: isVerifying
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Review & Continue",
                style: TextStyle(color: Colors.white),
              ),
      ),
    );
  }
}
