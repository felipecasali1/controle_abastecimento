import 'package:abastecimento_p2/core/utils/utils.dart';
import 'package:abastecimento_p2/features/auth/providers/auth_provider.dart';
import 'package:abastecimento_p2/features/refueling/data/model/refueling.dart';
import 'package:abastecimento_p2/features/refueling/presentation/refueling_list_page.dart';
import 'package:abastecimento_p2/features/refueling/providers/refueling_provider.dart';
import 'package:abastecimento_p2/features/vehicles/data/model/vehicle.dart';
import 'package:abastecimento_p2/features/vehicles/providers/vehicle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RefuelingRegisterPage extends StatefulWidget {
  const RefuelingRegisterPage({super.key});

  @override
  State<RefuelingRegisterPage> createState() => _RefuelingRegisterPageState();
}

class _RefuelingRegisterPageState extends State<RefuelingRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountPaidController = TextEditingController();
  final _litersController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();
  final _mileageController = TextEditingController();
  final _consumptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedVehicleId;
  String? _fuelType;

  @override
  void dispose() {
    _consumptionController.dispose();
    _litersController.dispose();
    _noteController.dispose();
    _mileageController.dispose();
    _dateController.dispose();
    _amountPaidController.dispose();
    super.dispose();
  }

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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dateController.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedVehicleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione um veículo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final authProvider = context.read<AuthProvider>();
      final refuelingProvider = context.read<RefuelingProvider>();

      double consumption = 0;
      final currentMileage = double.tryParse(_mileageController.text) ?? 0;
      final vehicleRefuelings = refuelingProvider.refuelings
          .where((r) => r.vehicleId == _selectedVehicleId)
          .toList();

      if (vehicleRefuelings.isNotEmpty) {
        vehicleRefuelings.sort((a, b) => a.mileage.compareTo(b.mileage));

        final lastRefueling = vehicleRefuelings.last;
        final kmDiff = currentMileage - lastRefueling.mileage;

        if (kmDiff > 0 && lastRefueling.liters > 0) {
          consumption = kmDiff / lastRefueling.liters;
        }
      }

      final refueling = Refueling(
        fuelType: _fuelType ?? '',
        vehicleId: _selectedVehicleId!,
        userId: authProvider.currentUser!.uid,
        date: _selectedDate,
        liters: double.tryParse(_litersController.text) ?? 0,
        mileage: double.tryParse(_mileageController.text) ?? 0,
        amountPaid: double.tryParse(_amountPaidController.text) ?? 0,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        consumption: consumption,
      );

      final success = await refuelingProvider.addRefueling(refueling);

      if (success && mounted) {
        refuelingProvider.loadRefuelings(authProvider.currentUser!.uid);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RefuelingListPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abastecimento registrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              refuelingProvider.errorMsg ?? 'Erro ao registrar abastecimento',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Abastecimento')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // PADRÃO DAS OUTRAS PAGES
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Novo Abastecimento',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),
                Consumer<VehicleProvider>(
                  builder: (context, provider, _) {
                    if (provider.vehicles.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Nenhum veículo cadastrado!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'Veículo',
                        border: OutlineInputBorder(),
                      ),
                      items: provider.vehicles.map((vehicle) {
                        return DropdownMenuItem(
                          value: vehicle.id,
                          child: Text('${vehicle.brand} ${vehicle.model}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedVehicleId = value);
                      },
                      validator: (value) =>
                          value == null ? 'Selecione um veículo' : null,
                    );
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                  ),
                  onTap: _selectDate,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecione uma data!';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _litersController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade de litros',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a quantidade de litros!';
                    }
                    final liters = double.tryParse(value);
                    if (liters == null || liters <= 0) {
                      return 'Quantidade inválida';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _amountPaidController,
                  decoration: const InputDecoration(
                    labelText: 'Valor Pago',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o valor pago';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Informe um valor válido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _mileageController,
                  decoration: const InputDecoration(
                    labelText: 'Quilometragem',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a quilometragem';
                    }
                    final km = double.tryParse(value);
                    if (km == null || km < 0) {
                      return 'Quilometragem inválida';
                    }

                    // km anterior
                    final vehicleProvider = context.read<VehicleProvider>();
                    if (_selectedVehicleId != null) {
                      final selectedVehicle = vehicleProvider.vehicles
                          .firstWhere((v) => v.id == _selectedVehicleId);

                      if (km < selectedVehicle.mileage) {
                        return 'A quilometragem deve ser maior que ${selectedVehicle.mileage}km';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Consumer<VehicleProvider>(
                  builder: (context, vehicleProvider, _) {
                    if (_selectedVehicleId == null) {
                      return const SizedBox.shrink();
                    }

                    return FutureBuilder<Vehicle?>(
                      future: vehicleProvider.getVehicleById(
                        _selectedVehicleId!,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final vehicle = snapshot.data!;
                        final vehicleFuelType = vehicle.fuelType;

                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Combustível',
                            border: OutlineInputBorder(),
                          ),
                          items: Utils.getCompatibleFuelTypes(vehicleFuelType)
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _fuelType = value);
                          },
                          validator: (value) =>
                              value == null ? 'Escolha um combustível' : null,
                          value: _fuelType,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Observação (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 20),

                Consumer<RefuelingProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _register,
                        child: const Text(
                          'Registrar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
