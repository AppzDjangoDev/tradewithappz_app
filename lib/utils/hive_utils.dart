// lib/utils/hive_utils.dart
import 'package:hive/hive.dart';
import '../models/app_log.dart';

Future<void> saveLoginResponse({
  required String accessToken,
  required String clientId,
  required String secretKey,
  required String timestamp,
  required String date,
}) async {
  final box = Hive.box<AppLog>('app_log_box');

  // Create an AppLog instance
  final appLog = AppLog(
    id: DateTime.now().millisecondsSinceEpoch, // Unique ID based on current time
    date: DateTime.parse(date),
    timestamp: timestamp,
    accessToken: accessToken,
    clientId: clientId,
    misc: '', // You can set this to an appropriate value if needed
    username: '' // You can set this to an appropriate value if needed
   
  );

  // Add to Hive box
  await box.add(appLog);
}
