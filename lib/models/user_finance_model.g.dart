// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_finance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IncomeTypeAdapterAdapter extends TypeAdapter<IncomeTypeAdapter> {
  @override
  final int typeId = 3;

  @override
  IncomeTypeAdapter read(BinaryReader reader) {
    return IncomeTypeAdapter();
  }

  @override
  void write(BinaryWriter writer, IncomeTypeAdapter obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomeTypeAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FinanceProfileAdapter extends TypeAdapter<FinanceProfile> {
  @override
  final int typeId = 14;

  @override
  FinanceProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinanceProfile(
      income: fields[0] as double,
      incomeType: fields[1] as IncomeType,
      savings: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, FinanceProfile obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.income)
      ..writeByte(1)
      ..write(obj.incomeType)
      ..writeByte(2)
      ..write(obj.savings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IncomeTypeAdapter extends TypeAdapter<IncomeType> {
  @override
  final int typeId = 3;

  @override
  IncomeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IncomeType.daily;
      case 1:
        return IncomeType.weekly;
      case 2:
        return IncomeType.monthly;
      default:
        return IncomeType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, IncomeType obj) {
    switch (obj) {
      case IncomeType.daily:
        writer.writeByte(0);
        break;
      case IncomeType.weekly:
        writer.writeByte(1);
        break;
      case IncomeType.monthly:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
