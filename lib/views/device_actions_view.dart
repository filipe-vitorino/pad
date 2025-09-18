import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../viewmodels/device_actions_viewmodel.dart';
import '../services/ble_service.dart';
import 'sync_options_view.dart';
import 'controller_view.dart';

class DeviceActionsView extends StatefulWidget {
  const DeviceActionsView({super.key});

  @override
  State<DeviceActionsView> createState() => _DeviceActionsViewState();
}

class _DeviceActionsViewState extends State<DeviceActionsView> {
  late DeviceActionsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Cria o ViewModel e adiciona um "ouvinte" para o estado da conexão
    _viewModel = DeviceActionsViewModel();
    _viewModel.connectionState.addListener(_onConnectionStateChanged);
  }

  @override
  void dispose() {
    // Remove o "ouvinte" para evitar fugas de memória
    _viewModel.connectionState.removeListener(_onConnectionStateChanged);
    _viewModel.dispose();

    // Esta tela é a dona da sessão, ela comanda a desconexão ao ser fechada.
    Future.delayed(Duration.zero, () {
      print("A sair da tela de ações, a desconectar...");
      BleService().disconnect();
    });

    super.dispose();
  }

  void _onConnectionStateChanged() {
    // Se a conexão for perdida enquanto esta tela estiver visível, volta para o scanner
    if (_viewModel.connectionState.value ==
            BluetoothConnectionState.disconnected &&
        mounted) {
      print("Conexão perdida na tela de Ações! A voltar para o scanner...");
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          // Obtém o nome do dispositivo do ViewModel para o título
          title: Text(context.watch<DeviceActionsViewModel>().deviceName),
          centerTitle: true,
        ),
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
                subtitle: "Baixar o histórico de registos.",
                color: Colors.purple.shade700,
                // Navega para a tela de opções (agora sem passar o 'device')
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SyncOptionsView(),
                      ),
                    ),
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
                        builder: (context) => const ControllerView(),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para criar os botões de ação
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
