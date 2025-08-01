/*
 * Título: View da Tela de Controle
 * Descrição: Interface gráfica para exibir os dados dos sensores.
 * Autor: Gemini
 * Data: 01 de Agosto de 2025
*/

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../viewmodels/controller_viewmodel.dart';

class ControllerView extends StatelessWidget {
  final BluetoothDevice device;
  const ControllerView({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    // Cria uma instância do ViewModel específica para esta tela
    return ChangeNotifierProvider(
      create: (_) => ControllerViewModel(device: device),
      child: Consumer<ControllerViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                device.platformName.isNotEmpty
                    ? device.platformName
                    : "Painel de Controle",
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Status: ${viewModel.connectionStatusText}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color:
                          viewModel.connectionState ==
                                  BluetoothConnectionState.connected
                              ? Colors.green.shade700
                              : Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSensorTile(
                    context,
                    'Vazão',
                    viewModel.sensorData?.vazao != null
                        ? '${viewModel.sensorData!.vazao!.toStringAsFixed(2)} L/min'
                        : '--',
                    Icons.waves,
                    Colors.blue.shade600,
                  ),
                  const SizedBox(height: 16),
                  _buildSensorTile(
                    context,
                    'Volume',
                    viewModel.sensorData?.volume != null
                        ? '${viewModel.sensorData!.volume!.toStringAsFixed(2)} L'
                        : '--',
                    Icons.opacity,
                    Colors.cyan.shade600,
                  ),
                  const SizedBox(height: 16),
                  _buildSensorTile(
                    context,
                    'Pressão',
                    viewModel.sensorData?.pressao != null
                        ? '${viewModel.sensorData!.pressao!.toStringAsFixed(2)} bar'
                        : '--',
                    Icons.compress,
                    Colors.orange.shade700,
                  ),
                  const SizedBox(height: 16),
                  _buildSensorTile(
                    context,
                    'Temperatura',
                    viewModel.sensorData?.temperatura != null
                        ? '${viewModel.sensorData!.temperatura!.toStringAsFixed(1)} °C'
                        : '--',
                    Icons.thermostat,
                    Colors.red.shade600,
                  ),
                  const SizedBox(height: 16),
                  _buildSensorTile(
                    context,
                    'TDS',
                    viewModel.sensorData?.tds != null
                        ? '${viewModel.sensorData!.tds!.toStringAsFixed(1)} ppm'
                        : '--',
                    Icons.science_outlined,
                    Colors.purple.shade500,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget de construção dos cards de sensores
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
            Column(
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
          ],
        ),
      ),
    );
  }
}
