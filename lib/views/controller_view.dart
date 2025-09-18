import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../viewmodels/controller_viewmodel.dart';

class ControllerView extends StatelessWidget {
  const ControllerView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ControllerViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Monitorização ao Vivo")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<ControllerViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.connectionState !=
                  BluetoothConnectionState.connected) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: SwitchListTile(
                        title: const Text("Ativar Fluxo de Dados"),
                        subtitle: const Text("Receber leituras em tempo real."),
                        value: viewModel.isStreaming,
                        onChanged: (value) {
                          viewModel.toggleStreaming(value);
                        },
                        secondary:
                            viewModel.isStreaming
                                ? const Icon(
                                  Icons.pause_circle,
                                  color: Colors.red,
                                )
                                : const Icon(
                                  Icons.play_circle,
                                  color: Colors.green,
                                ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSensorTile(
                      context,
                      'Vazão',
                      viewModel.realTimeData?.vazao?.toStringAsFixed(2) ?? '--',
                      Icons.waves,
                      Colors.blue.shade600,
                    ),
                    const SizedBox(height: 16),
                    _buildSensorTile(
                      context,
                      'Volume',
                      viewModel.realTimeData?.volume?.toStringAsFixed(2) ??
                          '--',
                      Icons.opacity,
                      Colors.cyan.shade600,
                    ),
                    const SizedBox(height: 16),
                    _buildSensorTile(
                      context,
                      'Pressão',
                      viewModel.realTimeData?.pressao?.toStringAsFixed(2) ??
                          '--',
                      Icons.compress,
                      Colors.orange.shade700,
                    ),
                    const SizedBox(height: 16),
                    _buildSensorTile(
                      context,
                      'Temperatura',
                      viewModel.realTimeData?.temperatura?.toStringAsFixed(1) ??
                          '--',
                      Icons.thermostat,
                      Colors.red.shade600,
                    ),
                    const SizedBox(height: 16),
                    _buildSensorTile(
                      context,
                      'TDS',
                      viewModel.realTimeData?.tds?.toStringAsFixed(1) ?? '--',
                      Icons.science_outlined,
                      Colors.purple.shade500,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSensorTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
