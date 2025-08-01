/*
 * Título: View da Tela de Login
 * Descrição: Interface gráfica para o utilizador inserir as suas credenciais.
 * Autor: Gemini
 * Data: 01 de Agosto de 2025
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import 'main_menu_view.dart'; // Precisamos criar este arquivo a seguir
import '../services/session_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _sessionService = SessionService(); // Instancie o serviço

  // ===== MUDANÇA IMPORTANTE AQUI =====
  @override
  void initState() {
    super.initState();
    // Verificamos a sessão assim que a tela é construída
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Atraso mínimo para garantir que o primeiro frame foi construído
    await Future.delayed(Duration.zero);

    if (await _sessionService.isLoggedIn()) {
      if (mounted) {
        print("Usuário já logado. Navegando para o menu...");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainMenuView()),
        );
      }
    } else {
      print("Nenhuma sessão encontrada. Exibindo tela de login.");
    }
  }

  void _performLogin() async {
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);

    final success = await viewModel.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      // Navega para o menu principal e remove a tela de login da pilha
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainMenuView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.sensors,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Sensor Control',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Utilizador (ex: email)',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _performLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Entrar', style: TextStyle(fontSize: 16)),
                ),
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
