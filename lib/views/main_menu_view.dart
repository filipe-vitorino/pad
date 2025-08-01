/*
 * Título: View do Menu Principal
 * Descrição: Exibe as opções principais de navegação da aplicação.
 * Autor: Gemini
 * Data: 01 de Agosto de 2025
*/

import 'package:flutter/material.dart';
import 'scanner_view.dart';
import 'wifi_scanner_view.dart';
import '../services/session_service.dart'; // Importe o serviço
import 'login_view.dart'; // Importe a tela de login

// Nome da classe alterado para seguir o padrão da arquitetura
class MainMenuView extends StatelessWidget {
  const MainMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              // Limpa a sessão
              await sessionService.clearSession();

              if (context.mounted) {
                // Navega de volta para o Login e remove todas as outras telas da pilha
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (Route<dynamic> route) =>
                      false, // Este predicado remove todas as rotas
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _MenuItem(
            title: 'Scanner BLE',
            subtitle: 'Conectar via Bluetooth Low Energy',
            icon: Icons.bluetooth_searching,
            color: Colors.blue.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScannerView()),
              );
            },
          ),
          const SizedBox(height: 16),
          _MenuItem(
            title: 'Scanner Wi-Fi (HTTP)',
            subtitle: 'Conectar via Wi-Fi Direct (AP Mode)',
            icon: Icons.wifi_find,
            color: Colors.green.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WifiScannerView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para os itens do menu
class _MenuItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 40, color: color),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
    );
  }
}
