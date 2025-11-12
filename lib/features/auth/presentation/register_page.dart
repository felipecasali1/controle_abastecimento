import 'package:abastecimento_p2/features/auth/presentation/login_page.dart';
import 'package:abastecimento_p2/features/auth/services/auth_service.dart';
import 'package:abastecimento_p2/features/home/presentation/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authServices = FirebaseServices();

  void _register() async {
    if(!_formKey.currentState!.validate()) {
      return;
    }

    try {
      UserCredential? userCred = await _authServices.signUpWithEmailPassword(_emailController.text, _passwordController.text);
      if (!mounted) return;
      if(userCred != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } 
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Abastecimento'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text('Cadastro'),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite seu e-mail!';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite sua senha!';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () => _register(),
                  child: Text('Cadastrar')
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  }, 
                  child: Text('Fazer login')
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}