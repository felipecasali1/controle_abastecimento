import 'package:abastecimento_p2/features/auth/providers/auth_provider.dart';
import 'package:abastecimento_p2/features/vehicles/data/model/vehicle.dart';
import 'package:abastecimento_p2/features/vehicles/providers/vehicle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class VehicleRegisterPage extends StatefulWidget {
  const VehicleRegisterPage({super.key});

  @override
  State<VehicleRegisterPage> createState() => _VehicleRegisterPageState();
}

class _VehicleRegisterPageState extends State<VehicleRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _brandController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  String _fuelType = 'Gasolina';

  final List<String> _fuelTypes = ['Gasolina', 'Etanol', 'Diesel', 'Flex'];

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _licensePlateController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final vehicleProvider = context.read<VehicleProvider>();

      final vehicle = Vehicle(
        userId: authProvider.currentUser!.uid,
        model: _modelController.text.trim(),
        brand: _brandController.text.trim(),
        licensePlate: _licensePlateController.text.trim().toUpperCase(),
        year: int.tryParse(_yearController.text) ?? 0,
        fuelType: _fuelType,
        mileage: double.tryParse(_mileageController.text) ?? 0,
      );

      final success = await vehicleProvider.addVehicle(vehicle);

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              vehicleProvider.errorMsg ??
                  'Erro ao cadastrar veículo! Tente novamente!',
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
      appBar: AppBar(title: const Text("Cadastrar Veículo")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // <- PADRÃO
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Novo Veículo',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe a marca!'
                      : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe o modelo!'
                      : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(
                    labelText: 'Ano de fabricação',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o ano!';
                    }
                    final year = int.tryParse(value);
                    final now = DateTime.now().year;
                    if (year == null || year < 1900 || year > now + 1) {
                      return 'Ano inválido!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _licensePlateController,
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(7),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a placa!';
                    }
                    if (value.length != 7) {
                      return 'A placa deve conter 7 caracteres!';
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
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a quilometragem!';
                    }
                    final mileage = double.tryParse(value);
                    if (mileage == null || mileage < 0) {
                      return 'Quilometragem inválida!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _fuelType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de combustível',
                    border: OutlineInputBorder(),
                  ),
                  items: _fuelTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _fuelType = value);
                    }
                  },
                ),

                const SizedBox(height: 28),

                Consumer<VehicleProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _register,
                        child: const Text(
                          'Cadastrar',
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
