import 'package:flutter/material.dart';
import 'http_controller_view.dart'; // A nossa tela de busca de dados
import 'wifi_sync_options_view.dart';

class WifiActionsView extends StatelessWidget {
  final String deviceName;
  const WifiActionsView({super.key, required this.deviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(deviceName)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionButton(
              context: context,
              icon: Icons.history,
              title: "Coletar Dados",
              subtitle: "Baixar o histórico de registos do aparelho via HTTP.",
              color: Colors.purple.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // O HttpControllerView agora é a tela de coleta de dados
                    builder:
                        (context) =>
                            WifiSyncOptionsView(deviceName: deviceName),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              context: context,
              icon: Icons.show_chart,
              title: "Verificar Aparelho",
              subtitle: "Monitorizar os sensores em tempo real.",
              color: Colors.teal.shade700,
              // Navega para a tela do controlador (agora sem passar o 'device')
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              HttpControllerView(deviceName: deviceName),
                    ),
                  ),
            ),
            // Adicione outros botões de ação Wi-Fi aqui no futuro
          ],
        ),
      ),
    );
  }

  // Pode reutilizar o mesmo widget de botão da DeviceActionsView do BLE
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onTap,
      child: Column(
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
