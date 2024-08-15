import 'package:hive/hive.dart';

part 'app_log.g.dart'; // Make sure this file exists and is generated

@HiveType(typeId: 0)
class AppLog extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String timestamp;

  @HiveField(3)
  final String accessToken;

  @HiveField(4)
  final String clientId;

  @HiveField(5)
  final String misc;

  @HiveField(6)
  final String username;

  AppLog({
    required this.id,
    required this.date,
    required this.timestamp,
    required this.accessToken,
    required this.clientId,
    required this.misc,
    required this.username,
  });
}
