import 'package:abastecimento_p2/features/auth/providers/auth_provider.dart';
import 'package:abastecimento_p2/features/refueling/data/model/refueling.dart';
import 'package:abastecimento_p2/features/refueling/providers/refueling_provider.dart';
import 'package:abastecimento_p2/features/vehicles/data/model/vehicle.dart';
import 'package:abastecimento_p2/features/vehicles/providers/vehicle_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RefuelingListPage extends StatefulWidget {
  const RefuelingListPage({super.key});

  @override
  State<RefuelingListPage> createState() => _RefuelingListPageState();
}

class _RefuelingListPageState extends State<RefuelingListPage> {
  Vehicle? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    final authProvider = context.read<AuthProvider>();
    final vehicleProvider = context.read<VehicleProvider>();
    if (authProvider.currentUser != null) {
      vehicleProvider.loadVehicles(authProvider.currentUser!.uid);
    }
  }

  void _loadRefuelings() {
    if (_selectedVehicle == null) return;
    final authProvider = context.read<AuthProvider>();
    final refuelingProvider = context.read<RefuelingProvider>();
    if (authProvider.currentUser != null) {
      refuelingProvider.loadRefuelingsByVehicle(
        authProvider.currentUser!.uid,
        _selectedVehicle!.id!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Abastecimentos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<VehicleProvider>(
              builder: (context, vehicleProvider, _) {
                if (vehicleProvider.isLoading) {
                  return const CircularProgressIndicator();
                }
                if (vehicleProvider.vehicles.isEmpty) {
                  return const Text('Nenhum veículo cadastrado!');
                }
                return DropdownButtonFormField<Vehicle>(
                  decoration: const InputDecoration(
                    labelText: 'Selecione o veículo',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedVehicle,
                  items: vehicleProvider.vehicles.map((vehicle) {
                    return DropdownMenuItem(
                      value: vehicle,
                      child: Text('${vehicle.brand} ${vehicle.model}'),
                    );
                  }).toList(),
                  onChanged: (vehicle) {
                    setState(() {
                      _selectedVehicle = vehicle;
                      _loadRefuelings();
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<RefuelingProvider>(
              builder: (context, refuelingProvider, _) {
                final vehicleProvider = context.read<VehicleProvider>();
                if (_selectedVehicle == null &&
                    vehicleProvider.vehicles.isNotEmpty) {
                  return const Center(
                    child: Text('Selecione um veículo acima'),
                  );
                }
                if (refuelingProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (refuelingProvider.refuelings.isEmpty) {
                  return const Center(
                    child: Text('Nenhum abastecimento encontrado!'),
                  );
                }
                return ListView.builder(
                  itemCount: refuelingProvider.refuelings.length,
                  itemBuilder: (context, index) {
                    final refueling = refuelingProvider.refuelings[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_gas_station),
                        title: Text(
                          '${refueling.date.day}/${refueling.date.month}/${refueling.date.year} - ${refueling.fuelType}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'R\$${refueling.amountPaid.toStringAsFixed(2)} - R\$${(refueling.amountPaid / refueling.liters).toStringAsFixed(2)}/L',
                            ),
                            Text('${refueling.liters} litros'),
                            Text('${refueling.mileage.toStringAsFixed(2)} km'),
                            Text(
                              'Consumo: ${refueling.consumption!.toStringAsFixed(2)} km/L',
                            ),
                            if (refueling.note != null &&
                                refueling.note!.trim().isNotEmpty)
                              Text('Obs: ${refueling.note}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDeletion(
                            context,
                            refueling,
                            refuelingProvider,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletion(
    BuildContext context,
    Refueling refueling,
    RefuelingProvider provider,
  ) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Deseja excluir este abastecimento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm && context.mounted) {
      final success = await provider.deleteRefueling(refueling);
      if (success) _loadRefuelings();
    }
  }
}
