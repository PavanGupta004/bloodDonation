import 'dart:convert';
import 'package:http/http.dart' as http;

class SMSService {
  static const String accountSid = 'AC49a9b7e956a596ce983ec2f496d7b082';
  static const String authToken = '3e7e62e89751d07c03a89181f16ed0ac';
  static const String fromNumber = '+17178836643';

  static Future<bool> sendSMS(String toNumber, String message) async {
    try {
      final url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json',
      );
      final credentials = base64Encode(utf8.encode('$accountSid:$authToken'));

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'From': fromNumber, 'To': toNumber, 'Body': message},
      );

      return response.statusCode == 201;
    } catch (e) {
      print('SMS Error: $e');
      return false;
    }
  }
}
