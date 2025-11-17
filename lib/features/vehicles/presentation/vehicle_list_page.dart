import 'package:abastecimento_p2/features/auth/providers/auth_provider.dart';
import 'package:abastecimento_p2/features/vehicles/data/model/vehicle.dart';
import 'package:abastecimento_p2/features/vehicles/presentation/vehicle_register_page.dart';
import 'package:abastecimento_p2/features/vehicles/providers/vehicle_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VehicleListPage extends StatefulWidget {
  const VehicleListPage({super.key});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meus Veículos")),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.vehicles.isEmpty) {
            return const Center(child: Text('Nenhum veículo encontrado!'));
          }
          return ListView.builder(
            itemCount: provider.vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = provider.vehicles[index];
              return _buildVehicleCard(context, vehicle, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VehicleRegisterPage()),
          );
          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veículo cadastrado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    Vehicle vehicle,
    VehicleProvider provider,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(Icons.directions_car)),
        title: Text('${vehicle.brand} ${vehicle.model} ${vehicle.year}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Placa: ${vehicle.licensePlate}'),
            Text('Combustível: ${vehicle.fuelType}'),
            Text('Quilometragem: ${vehicle.mileage}km'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _confirmDeletion(context, vehicle, provider),
        ),
      ),
    );
  }

  Future<void> _confirmDeletion(
    BuildContext context,
    Vehicle vehicle,
    VehicleProvider provider,
  ) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar'),
        content: Text(
          'Deseja excluir o veículo ${vehicle.brand} ${vehicle.model}?',
        ),
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
      final success = await provider.delete(vehicle);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veículo excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
