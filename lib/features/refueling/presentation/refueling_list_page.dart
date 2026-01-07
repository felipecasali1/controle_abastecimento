import 'package:abastecimento_p2/features/auth/providers/auth_provider.dart';
import 'package:abastecimento_p2/features/refueling/data/model/refueling.dart';
import 'package:abastecimento_p2/features/refueling/presentation/refueling_register_page.dart';
import 'package:abastecimento_p2/features/refueling/providers/refueling_provider.dart';
import 'package:abastecimento_p2/features/vehicles/providers/vehicle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RefuelingListPage extends StatefulWidget {
  const RefuelingListPage({super.key});

  @override
  State<RefuelingListPage> createState() => _RefuelingListPageState();
}

class _RefuelingListPageState extends State<RefuelingListPage> {
  String? _selectedVehicleId;

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
    if (_selectedVehicleId == null) return;
    final authProvider = context.read<AuthProvider>();
    final refuelingProvider = context.read<RefuelingProvider>();
    refuelingProvider.clearRefuelings();
    if (authProvider.currentUser != null) {
      refuelingProvider.loadRefuelingsByVehicle(
        authProvider.currentUser!.uid,
        _selectedVehicleId!,
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
                  return const SizedBox(height: 0);
                }
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Selecione o veículo!',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedVehicleId,
                    items: vehicleProvider.vehicles.map((vehicle) {
                      return DropdownMenuItem(
                        value: vehicle.id,
                        child: Text('${vehicle.brand} ${vehicle.model}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedVehicleId = value;
                        _loadRefuelings();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<RefuelingProvider>(
              builder: (context, refuelingProvider, _) {
                final vehicleProvider = context.read<VehicleProvider>();
                if (_selectedVehicleId == null &&
                    vehicleProvider.vehicles.isNotEmpty) {
                  return const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_upward, color: Colors.grey),
                        Text('  Selecione um veículo acima!'),
                      ],
                    ),
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
                        minVerticalPadding: 24,
                        onLongPress: () async {
                          await Clipboard.setData(
                            ClipboardData(
                              text:
                                  '${refueling.date.day}/${refueling.date.month}/${refueling.date.year} - ${refueling.fuelType}\n' +
                                  'Total: R\$${refueling.amountPaid.toStringAsFixed(2)}\n' +
                                  'Preço por litro: R\$${(refueling.amountPaid / refueling.liters).toStringAsFixed(2)}/L\n' +
                                  'Litros abastecidos: ${refueling.liters}L\n' +
                                  'Hodômetro: ${refueling.mileage.toStringAsFixed(2)}km\n' +
                                  'Consumo: ${refueling.consumption!.toStringAsFixed(2)}km/L\n' +
                                  'Obs: ${refueling.note}',
                            ),
                          ).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copiado para o clipboard!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          });
                        },
                        leading: Icon(Icons.local_gas_station),
                        title: Text(
                          '${refueling.date.day}/${refueling.date.month}/${refueling.date.year} - ${refueling.fuelType}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Total: '),
                                Spacer(),
                                Text(
                                  'R\$${refueling.amountPaid.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('Preço por litro: '),
                                Spacer(),
                                Text(
                                  'R\$${(refueling.amountPaid / refueling.liters).toStringAsFixed(2)}/L',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('Litros abastecidos: '),
                                Spacer(),
                                Text(
                                  '${refueling.liters}L',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('Hodômetro: '),
                                Spacer(),
                                Text(
                                  '${refueling.mileage.toStringAsFixed(2)}km',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            refueling.consumption! <= 0.00
                                ? SizedBox()
                                : Row(
                                    children: [
                                      Text('Consumo: '),
                                      Spacer(),
                                      Text(
                                        '${refueling.consumption!.toStringAsFixed(2)}km/L',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RefuelingRegisterPage(
                preselectedVehicleId: _selectedVehicleId,
              ),
            ),
          );
          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Abastecimento cadastrado com sucesso!',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Abastecer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
