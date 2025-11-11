import 'package:abastecimento_p2/core/theme/app_theme.dart';
import 'package:abastecimento_p2/features/auth/presentation/login_page.dart';
import 'package:abastecimento_p2/features/home/presentation/home_page.dart';
import 'package:abastecimento_p2/routes/app_routes.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Abastecimento',
      theme: customTheme,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.home: (context) => const HomePage(),
        //AppRoutes.vehicles: (context) => const VehiclesListPage(),
        //AppRoutes.fuel: (context) => const FuelListPage(),
      },
    );
  }
}