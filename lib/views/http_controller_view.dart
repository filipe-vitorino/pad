/*
 * Título: View do Controlador HTTP
 * Descrição: Interface para exibir dados de sensores vindos de um servidor HTTP.
 * Autor: Gemini
 * Data: 01 de Agosto de 2025
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/http_controller_viewmodel.dart';

class HttpControllerView extends StatelessWidget {
  final String deviceName;

  const HttpControllerView({super.key, required this.deviceName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HttpControllerViewModel(deviceName: deviceName),
      child: Consumer<HttpControllerViewModel>(
        builder: (context, viewModel, child) {
          final sensorData = viewModel.sensorData;
          return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.deviceName),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Status: ${viewModel.connectionStatus}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color:
                          viewModel.hasError
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSensorTile(
                    context,
                    'Vazão',
                    sensorData?.vazao != null
                        ? '${sensorData!.vazao!.toStringAsFixed(2)} L/min'
                        : '--',
                    Icons.waves,
                    Colors.blue.shade600,
                  ),
                  const SizedBox(height: 16),
                  _buildSensorTile(
                    context,
                    'Volume',
                    sensorData?.volume != null
                        ? '${sensorData!.volume!.toStringAsFixed(2)} L'
                        : '--',
                    Icons.opacity,
                    Colors.cyan.shade600,
                  ),
                  const SizedBox(height: 16),
                  _buildSensorTile(
                    context,
                    'Pressão',
                    sensorData?.pressao != null
                        ? '${sensorData!.pressao!.toStringAsFixed(2)} bar'
                        : '--',
                    Icons.compress,
                    Colors.orange.shade700,
                  ),
                  const SizedBox(height: 16),
                  _buildSensorTile(
                    context,
                    'Temperatura',
                    sensorData?.temperatura != null
                        ? '${sensorData!.temperatura!.toStringAsFixed(1)} °C'
                        : '--',
                    Icons.thermostat,
                    Colors.red.shade600,
                  ),
                  const SizedBox(height: 16),
                  _buildSensorTile(
                    context,
                    'TDS',
                    sensorData?.tds != null
                        ? '${sensorData!.tds!.toStringAsFixed(1)} ppm'
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

  // Widget de UI pode permanecer na View
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
