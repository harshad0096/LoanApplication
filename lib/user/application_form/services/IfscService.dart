import 'dart:convert';
import 'package:http/http.dart' as http;

class IfscService {
  /// Get bank details using IFSC
  static Future<Map<String, dynamic>?> fetchDetails(String ifsc) async {
    try {
      final response = await http.get(
        Uri.parse("https://ifsc.razorpay.com/$ifsc"),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch bank list (real banks)
  static Future<List<String>> fetchBanks(String query) async {
    try {
      final response = await http.get(
        Uri.parse("https://api.github.com/repos/razorpay/ifsc/contents/data"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<String> banks = data
            .map<String>((e) => e['name'].toString().replaceAll('.json', ''))
            .toList();

        return banks
            .where((bank) => bank.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    } catch (e) {}

    return [];
  }
}
