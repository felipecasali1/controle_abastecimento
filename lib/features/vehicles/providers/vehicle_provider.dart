import 'package:abastecimento_p2/features/vehicles/data/model/vehicle.dart';
import 'package:abastecimento_p2/features/vehicles/services/vehicle_service.dart';
import 'package:flutter/material.dart';

class VehicleProvider with ChangeNotifier {
  final VehicleService _vehicleService = VehicleService();

  List<Vehicle> _vehicles = [];

  List<Vehicle> get vehicles => _vehicles;

  bool isLoading = false;
  String? errorMsg;

  void loadVehicles(String userId) {
    _vehicleService
        .listByUserId(userId)
        .listen(
          (vehicles) {
            _vehicles = vehicles;
            isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            errorMsg = 'Erro ao carregar veículos!';
            isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<bool> addVehicle(Vehicle vehicle) async {
    try {
      isLoading = true;
      notifyListeners();

      await _vehicleService.create(vehicle);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMsg = 'Erro ao adicionar veículo!';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(Vehicle vehicle) async {
    try {
      isLoading = true;
      notifyListeners();

      await _vehicleService.delete(vehicle);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMsg = 'Erro ao excluir veículo!';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Vehicle?> getVehicleById(String id) async {
    try {
      return _vehicleService.getVehicleById(id);
    } catch (e) {
      return null;
    }
  }
}
