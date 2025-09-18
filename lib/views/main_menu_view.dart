import 'package:flutter/material.dart';
import '../services/session_service.dart';
import 'login_view.dart';
import 'scanner_view.dart';
import 'wifi_scanner_view.dart';
import 'stress_test_view.dart';
import 'reading_history_view.dart';

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
              await sessionService.clearSession();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (Route<dynamic> route) => false,
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
                MaterialPageRoute(
                  builder: (context) => const ScannerView(),
                  // --- ADIÇÃO AQUI ---
                  // Damos um nome único a esta rota
                  settings: const RouteSettings(name: '/scanner'),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _MenuItem(
            title: 'Scanner Wi-Fi (HTTP)',
            subtitle: 'Conectar via Wi-Fi Direct (AP Mode)',
            icon: Icons.wifi_find,
            color: Colors.green.shade700,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WifiScannerView(),
                  ),
                ),
          ),
          const SizedBox(height: 16),
          _MenuItem(
            title: 'Teste de Estresse BLE',
            subtitle: 'Executar 100 ciclos de conexão',
            icon: Icons.autorenew,
            color: Colors.red.shade700,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StressTestView(),
                  ),
                ),
          ),
          const SizedBox(height: 16),
          _MenuItem(
            title: 'Histórico de Leituras',
            subtitle: 'Ver dados salvos no dispositivo',
            icon: Icons.history_edu,
            color: Colors.purple.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReadingHistoryView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title, subtitle;
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
  Widget build(BuildContext context) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: Icon(icon, size: 40, color: color),
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
  );
}
