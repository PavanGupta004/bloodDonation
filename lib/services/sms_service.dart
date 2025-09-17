// lib/services/sms_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SMSService {
  // static String get accountSid => dotenv.env['TWILIO_ACCOUNT_SID']!;
  // static String get authToken => dotenv.env['TWILIO_AUTH_TOKEN']!;
  // static String get fromNumber => dotenv.env['TWILIO_FROM_NUMBER']!;
  static String accountSid = 'AC49a9b7e956a596ce983ec2f496d7b082';
  static String authToken = '5d1d5375778fb8336019d88e64fd2f3d';
  static String fromNumber = '+17178836643';

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
