// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/hive_utils.dart';

Future<void> loginUser(String username, String password) async {
  final response = await http.post(
    Uri.parse('https://your.api.endpoint/login/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'password': password}),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);

    // Extract fields from response
    final accessToken = responseData['access_token'];
    final clientId = responseData['client_id'];
    final secretKey = responseData['secret_key'];
    final timestamp = responseData['timestamp'];
    final date = responseData['date'];

    // Save to Hive
    await saveLoginResponse(
      accessToken: accessToken,
      clientId: clientId,
      secretKey: secretKey,
      timestamp: timestamp,
      date: date,
    );
  } else {
    throw Exception('Failed to log in');
  }
}
