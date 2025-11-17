import 'package:abastecimento_p2/features/refueling/data/model/refueling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RefuelingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> create(Refueling refueling) async {
    try {
      await _firestore.collection('refuelings').add(refueling.toMap());
    } catch (e) {
      throw Exception('Erro ao cadastrar abastecimento!');
    }
  }

  Stream<List<Refueling>> listByUserId(String userId) {
    return _firestore
        .collection('refuelings')
        .where('userId', isEqualTo: userId)
        .orderBy('brand')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Refueling.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Stream<List<Refueling>> listByVehicleId(String userId, String vehicleId) {
    return _firestore
        .collection('refuelings')
        .where('userId', isEqualTo: userId)
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('mileage', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Refueling.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> update(Refueling refueling, String id) async {
    try {
      await _firestore
          .collection('refuelings')
          .doc(refueling.id)
          .update(refueling.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar abastecimento!');
    }
  }

  Future<void> delete(Refueling refueling) async {
    try {
      await _firestore.collection('refuelings').doc(refueling.id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar abastecimento!');
    }
  }
}
