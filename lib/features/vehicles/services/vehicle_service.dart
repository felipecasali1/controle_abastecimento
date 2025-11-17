import 'package:abastecimento_p2/features/vehicles/data/model/vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> create(Vehicle vehicle) async {
    try {
      await _firestore.collection('vehicles').add(vehicle.toMap());
    } catch (e) {
      throw Exception('Erro ao criar veículo!');
    }
  }

  Stream<List<Vehicle>> listByUserId(String userId) {
    return _firestore
        .collection('vehicles')
        .where('userId', isEqualTo: userId)
        .orderBy('brand')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Vehicle.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<Vehicle?> getVehicleById(String id) async {
    final doc = await _firestore.collection('vehicles').doc(id).get();
    if (doc.exists) {
      return Vehicle.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> updateMileage(Vehicle vehicle, double newMileage) async {
    try {
      final updatedVehicle = vehicle.copyWith(mileage: newMileage);

      await _firestore
          .collection('vehicles')
          .doc(vehicle.id)
          .update(updatedVehicle.toMap());
    } catch (e) {
      throw Exception('Erro ao editar veículo!');
    }
  }

  Future<void> delete(Vehicle vehicle) async {
    try {
      final vehicleRefuelings = await _firestore
          .collection('refuelings')
          .where('vehicleId', isEqualTo: vehicle.id)
          .get();

      for (var doc in vehicleRefuelings.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection('vehicles').doc(vehicle.id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar veículo!');
    }
  }
}
