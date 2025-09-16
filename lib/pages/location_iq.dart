import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> reverseGeocodeWithLocationIQ({
  required double lat,
  required double lon,
  required String apiKey,
}) async {
  final url =
      'https://us1.locationiq.com/v1/reverse.php?key=$apiKey&lat=$lat&lon=$lon&format=json';

  try {
    print(lat);
    print(lon);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // LocationIQ returns "display_name" for human-readable address
      if (data['display_name'] != null) {
        return data['display_name'];
      } else {
        return "Address not found";
      }
    } else {
      throw Exception('Failed to fetch address: ${response.body}');
    }
  } catch (e) {
    throw Exception('Reverse geocoding failed: $e');
  }
}
