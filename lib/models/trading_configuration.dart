// lib/models/trading_configuration.dart
import 'package:hive/hive.dart';

part 'trading_configuration.g.dart'; // This will be generated

@HiveType(typeId: 1)
class TradingConfiguration extends HiveObject {
  @HiveField(0)
  final double defaultStoploss;

  @HiveField(1)
  final int defaultOrderQty;

  @HiveField(2)
  final int rewardRatio;

  @HiveField(3)
  final int maxLoss;

  @HiveField(4)
  final int maxTradeCount;

  @HiveField(5)
  final int capitalLimitPerOrder;

  @HiveField(6)
  final int capitalUsageLimit;

  @HiveField(7)
  final int forwardTrailingPoints;

  @HiveField(8)
  final int trailingToTopPoints;

  @HiveField(9)
  final int reverseTrailingPoints;

  @HiveField(10)
  final double stoplossLimitSlippage;

  @HiveField(11)
  final DateTime lastUpdated;

  @HiveField(12)
  final int? averagingLimit;

  @HiveField(13)
  final String orderQuantityMode;

  @HiveField(14)
  final int scalpingAmountLimit;

  @HiveField(15)
  final bool scalpingMode;

  @HiveField(16)
  final double scalpingStoploss;

  @HiveField(17)
  final int? scalpingRatio;

  @HiveField(18)
  final int? straddleAmountLimit;

  @HiveField(19)
  final int? straddleCapitalUsage;

  @HiveField(20)
  final bool overTradeStatus;

  @HiveField(21)
  final int averagingQty;

  @HiveField(22)
  final String activeBroker;

  TradingConfiguration({
    required this.defaultStoploss,
    required this.defaultOrderQty,
    required this.rewardRatio,
    required this.maxLoss,
    required this.maxTradeCount,
    required this.capitalLimitPerOrder,
    required this.capitalUsageLimit,
    required this.forwardTrailingPoints,
    required this.trailingToTopPoints,
    required this.reverseTrailingPoints,
    required this.stoplossLimitSlippage,
    required this.lastUpdated,
    this.averagingLimit,
    required this.orderQuantityMode,
    required this.scalpingAmountLimit,
    required this.scalpingMode,
    required this.scalpingStoploss,
    this.scalpingRatio,
    this.straddleAmountLimit,
    this.straddleCapitalUsage,
    required this.overTradeStatus,
    required this.averagingQty,
    required this.activeBroker,
  });
}
