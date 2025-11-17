import 'package:abastecimento_p2/features/refueling/data/model/refueling.dart';
import 'package:abastecimento_p2/features/refueling/services/refueling_service.dart';
import 'package:abastecimento_p2/features/vehicles/data/model/vehicle.dart';
import 'package:abastecimento_p2/features/vehicles/services/vehicle_service.dart';
import 'package:flutter/material.dart';

class RefuelingProvider with ChangeNotifier {
  final RefuelingService _refuelingService = RefuelingService();
  final VehicleService _vehicleService = VehicleService();

  List<Refueling> _refuelings = [];

  List<Refueling> get refuelings => _refuelings;

  bool isLoading = false;
  String? errorMsg;

  void loadRefuelings(String userId) {
    _refuelingService
        .listByUserId(userId)
        .listen(
          (refuelings) {
            _refuelings = refuelings;
            isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            errorMsg = 'Erro ao carregar abastecimentos!';
            isLoading = false;
            notifyListeners();
          },
        );
  }

  void loadRefuelingsByVehicle(String userId, String vehicleId) {
    _refuelingService
        .listByVehicleId(userId, vehicleId)
        .listen(
          (refuelings) {
            _refuelings = refuelings;
            isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            errorMsg = 'Erro ao carregar abastecimentos!';
            isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<bool> addRefueling(Refueling refueling) async {
    try {
      isLoading = true;
      notifyListeners();
      await _refuelingService.create(refueling);
      Vehicle? vehicle = await _vehicleService.getVehicleById(
        refueling.vehicleId,
      );

      if (vehicle == null) {
        errorMsg = 'Veículo não encontrado!';
        isLoading = false;
        notifyListeners();
        return false;
      }

      await _vehicleService.updateMileage(vehicle, refueling.mileage);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMsg = 'Erro ao adicionar abastecimento!';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRefueling(Refueling refueling) async {
    try {
      isLoading = true;
      notifyListeners();

      await _refuelingService.delete(refueling);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMsg = 'Erro ao excluir abastecimento!';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
