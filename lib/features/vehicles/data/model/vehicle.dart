class Vehicle {
  final String? id;
  final String userId;
  final String model;
  final String brand;
  final String licensePlate;
  final String fuelType;
  final int year;
  final double mileage;

  Vehicle({
    this.id,
    required this.userId,
    required this.model,
    required this.brand,
    required this.licensePlate,
    required this.year,
    required this.fuelType,
    required this.mileage,
  });

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'brand': brand,
      'licensePlate': licensePlate,
      'year': year,
      'fuelType': fuelType,
      'mileage': mileage,
      'userId': userId,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map, String id) {
    return Vehicle(
      id: id,
      userId: map['userId'] ?? '',
      model: map['model'] ?? '',
      brand: map['brand'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      year: (map['year'] ?? 0).toInt(),
      fuelType: map['fuelType'] ?? '',
      mileage: (map['mileage'] ?? 0).toDouble(),
    );
  }

  Vehicle copyWith({
    String? id,
    String? userId,
    String? model,
    String? brand,
    String? licensePlate,
    int? year,
    String? fuelType,
    double? mileage,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      model: model ?? this.model,
      brand: brand ?? this.brand,
      licensePlate: licensePlate ?? this.licensePlate,
      year: year ?? this.year,
      fuelType: fuelType ?? this.fuelType,
      mileage: mileage ?? this.mileage,
    );
  }
}
