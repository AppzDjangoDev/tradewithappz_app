// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trading_configuration.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TradingConfigurationAdapter extends TypeAdapter<TradingConfiguration> {
  @override
  final int typeId = 1;

  @override
  TradingConfiguration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TradingConfiguration(
      defaultStoploss: fields[0] as double,
      defaultOrderQty: fields[1] as int,
      rewardRatio: fields[2] as int,
      maxLoss: fields[3] as int,
      maxTradeCount: fields[4] as int,
      capitalLimitPerOrder: fields[5] as int,
      capitalUsageLimit: fields[6] as int,
      forwardTrailingPoints: fields[7] as int,
      trailingToTopPoints: fields[8] as int,
      reverseTrailingPoints: fields[9] as int,
      stoplossLimitSlippage: fields[10] as double,
      lastUpdated: fields[11] as DateTime,
      averagingLimit: fields[12] as int?,
      orderQuantityMode: fields[13] as String,
      scalpingAmountLimit: fields[14] as int,
      scalpingMode: fields[15] as bool,
      scalpingStoploss: fields[16] as double,
      scalpingRatio: fields[17] as int?,
      straddleAmountLimit: fields[18] as int?,
      straddleCapitalUsage: fields[19] as int?,
      overTradeStatus: fields[20] as bool,
      averagingQty: fields[21] as int,
      activeBroker: fields[22] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TradingConfiguration obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.defaultStoploss)
      ..writeByte(1)
      ..write(obj.defaultOrderQty)
      ..writeByte(2)
      ..write(obj.rewardRatio)
      ..writeByte(3)
      ..write(obj.maxLoss)
      ..writeByte(4)
      ..write(obj.maxTradeCount)
      ..writeByte(5)
      ..write(obj.capitalLimitPerOrder)
      ..writeByte(6)
      ..write(obj.capitalUsageLimit)
      ..writeByte(7)
      ..write(obj.forwardTrailingPoints)
      ..writeByte(8)
      ..write(obj.trailingToTopPoints)
      ..writeByte(9)
      ..write(obj.reverseTrailingPoints)
      ..writeByte(10)
      ..write(obj.stoplossLimitSlippage)
      ..writeByte(11)
      ..write(obj.lastUpdated)
      ..writeByte(12)
      ..write(obj.averagingLimit)
      ..writeByte(13)
      ..write(obj.orderQuantityMode)
      ..writeByte(14)
      ..write(obj.scalpingAmountLimit)
      ..writeByte(15)
      ..write(obj.scalpingMode)
      ..writeByte(16)
      ..write(obj.scalpingStoploss)
      ..writeByte(17)
      ..write(obj.scalpingRatio)
      ..writeByte(18)
      ..write(obj.straddleAmountLimit)
      ..writeByte(19)
      ..write(obj.straddleCapitalUsage)
      ..writeByte(20)
      ..write(obj.overTradeStatus)
      ..writeByte(21)
      ..write(obj.averagingQty)
      ..writeByte(22)
      ..write(obj.activeBroker);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradingConfigurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
