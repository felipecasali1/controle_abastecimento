import 'package:cloud_firestore/cloud_firestore.dart';

class Refueling {
  final String? id;
  final String fuelType;
  final String vehicleId;
  final String? note;
  final String userId;
  final DateTime date;
  final double liters;
  final double mileage;
  final double amountPaid;
  final double? consumption;

  Refueling({
    this.id,
    required this.fuelType,
    required this.vehicleId,
    this.note,
    required this.userId,
    required this.date,
    required this.liters,
    required this.mileage,
    required this.amountPaid,
    this.consumption,
  });

  Map<String, dynamic> toMap() {
    return {
      'fuelType': fuelType,
      'vehicleId': vehicleId,
      'note': note,
      'userId': userId,
      'date': date,
      'liters': liters,
      'mileage': mileage,
      'amountPaid': amountPaid,
      'consumption': consumption,
    };
  }

  factory Refueling.fromMap(Map<String, dynamic> map, String id) {
    return Refueling(
      id: id,
      fuelType: map['fuelType'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      note: map['note'] ?? '',
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      liters: (map['liters'] ?? 0).toDouble(),
      mileage: (map['mileage'] ?? 0).toDouble(),
      amountPaid: (map['amountPaid'] ?? 0).toDouble(),
      consumption: (map['consumption'] ?? 0).toDouble(),
    );
  }

  Refueling copyWith({
    String? id,
    String? fuelType,
    String? vehicleId,
    String? note,
    String? userId,
    DateTime? date,
    double? liters,
    double? mileage,
    double? amountPaid,
    double? consumption,
  }) {
    return Refueling(
      id: id ?? this.id,
      fuelType: fuelType ?? this.fuelType,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      liters: liters ?? this.liters,
      mileage: mileage ?? this.mileage,
      amountPaid: amountPaid ?? this.amountPaid,
      note: note ?? this.note,
      consumption: consumption ?? this.consumption,
    );
  }
}
