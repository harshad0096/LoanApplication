import '../models/bank_model.dart';

class BankService {
  static List<BankModel> banks = [
    BankModel(
      name: "State Bank of India",
      logo: "https://upload.wikimedia.org/wikipedia/commons/c/cc/SBI-logo.svg",
    ),
    BankModel(
      name: "HDFC Bank",
      logo:
          "https://upload.wikimedia.org/wikipedia/commons/2/28/HDFC_Bank_Logo.svg",
    ),
    BankModel(
      name: "ICICI Bank",
      logo:
          "https://upload.wikimedia.org/wikipedia/commons/1/12/ICICI_Bank_Logo.svg",
    ),
    BankModel(
      name: "Axis Bank",
      logo:
          "https://upload.wikimedia.org/wikipedia/commons/1/1a/Axis_Bank_logo.svg",
    ),
    BankModel(
      name: "Kotak Mahindra Bank",
      logo:
          "https://upload.wikimedia.org/wikipedia/commons/0/0c/Kotak_Mahindra_Bank_logo.svg",
    ),
    BankModel(
      name: "Punjab National Bank",
      logo:
          "https://upload.wikimedia.org/wikipedia/commons/3/35/Punjab_National_Bank_logo.svg",
    ),
    BankModel(
      name: "Bank of Baroda",
      logo:
          "https://upload.wikimedia.org/wikipedia/commons/5/55/Bank_of_Baroda_logo.svg",
    ),
    BankModel(
      name: "Union Bank of India",
      logo:
          "https://upload.wikimedia.org/wikipedia/en/5/5a/Union_Bank_of_India_Logo.svg",
    ),
    BankModel(
      name: "Canara Bank",
      logo:
          "https://upload.wikimedia.org/wikipedia/commons/5/5f/Canara_Bank_Logo.svg",
    ),
    BankModel(
      name: "IndusInd Bank",
      logo:
          "https://upload.wikimedia.org/wikipedia/commons/4/48/IndusInd_Bank_logo.svg",
    ),
    BankModel(
      name: "Yes Bank",
      logo:
          "https://upload.wikimedia.org/wikipedia/commons/0/00/Yes_Bank_SVG_Logo.svg",
    ),
    BankModel(
      name: "IDFC First Bank",
      logo:
          "https://upload.wikimedia.org/wikipedia/commons/6/6c/IDFC_First_Bank_logo.svg",
    ),
    BankModel(
      name: "AU Small Finance Bank",
      logo:
          "https://upload.wikimedia.org/wikipedia/commons/9/9c/AU_Small_Finance_Bank_Logo.svg",
    ),
    BankModel(
      name: "UCO Bank",
      logo: "https://upload.wikimedia.org/wikipedia/en/3/3f/UCO_Bank_logo.svg",
    ),
    BankModel(
      name: "Indian Bank",
      logo:
          "https://upload.wikimedia.org/wikipedia/en/7/73/Indian_Bank_logo.svg",
    ),
  ];

  static Future<List<BankModel>> searchBanks(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return banks
        .where((bank) => bank.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
