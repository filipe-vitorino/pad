import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../models/device_config.dart';
import '../viewmodels/controller_viewmodel.dart';

class ControllerView extends StatelessWidget {
  const ControllerView({super.key});

  static const Map<String, String> sensorDisplayNames = {
    'vazao': 'Vazão',
    'pressao': 'Pressão',
    'volume': 'Volume',
    'tds': 'TDS',
    'temperatura': 'Temperatura',
  };

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ControllerViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Dashboard de Monitorização")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<ControllerViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.connectionState !=
                  BluetoothConnectionState.connected) {
                return const Center(child: CircularProgressIndicator());
              }

              final buttonStyle =
                  viewModel.isStreaming
                      ? ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      )
                      : ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      );
              final buttonIcon =
                  viewModel.isStreaming
                      ? Icons.pause_circle
                      : Icons.play_circle;
              final buttonText =
                  viewModel.isStreaming
                      ? "Parar Monitorização"
                      : "Iniciar Monitorização";

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(buttonIcon),
                        label: Text(buttonText),
                        style: buttonStyle.copyWith(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 16),
                          ),
                          textStyle: MaterialStateProperty.all(
                            const TextStyle(fontSize: 18),
                          ),
                        ),
                        onPressed:
                            () => viewModel.toggleStreaming(
                              !viewModel.isStreaming,
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- GRUPOS REFEITOS PARA O LAYOUT CORRETO ---
                    _buildGroupCard(
                      context: context,
                      viewModel: viewModel,
                      title: "Funcionamento do Aparelho",
                      icon: Icons.settings_outlined,
                      // Passamos as chaves dos sensores para este grupo
                      sensorKeys: ['vazao', 'pressao', 'volume'],
                    ),
                    const SizedBox(height: 16),
                    _buildGroupCard(
                      context: context,
                      viewModel: viewModel,
                      title: "Qualidade da Água",
                      icon: Icons.water_drop_outlined,
                      // Passamos as chaves dos sensores para este grupo
                      sensorKeys: ['tds', 'temperatura'],
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

  /// Constrói um "card-mãe" que agora também gere o layout dos seus filhos.
  Widget _buildGroupCard({
    required BuildContext context,
    required ControllerViewModel viewModel,
    required String title,
    required IconData icon,
    required List<String> sensorKeys,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final double itemWidth = (constraints.maxWidth - 16) / 2;

                List<Widget> squares =
                    sensorKeys.map((key) {
                      IconData sensorIcon = Icons.help;
                      switch (key) {
                        case 'vazao':
                          sensorIcon = Icons.waves;
                          break;
                        case 'pressao':
                          sensorIcon = Icons.compress;
                          break;
                        case 'volume':
                          sensorIcon = Icons.opacity;
                          break;
                        case 'tds':
                          sensorIcon = Icons.science_outlined;
                          break;
                        case 'temperatura':
                          sensorIcon = Icons.thermostat;
                          break;
                      }

                      // O mapa de nomes agora é acedido através da classe
                      final String displayTitle =
                          sensorDisplayNames[key] ?? key;

                      return _buildStatusSquare(
                        context: context,
                        title: displayTitle,
                        icon: sensorIcon,
                        isOk: viewModel.isSensorOk(key),
                        size: itemWidth,
                      );
                    }).toList();

                return Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.center,
                  children: squares,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  //      >>> WIDGET DOS QUADRADOS MODIFICADO <<<
  // ==========================================================
  /// Widget auxiliar que agora recebe um 'size' para garantir que seja um quadrado.
  Widget _buildStatusSquare({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isOk,
    required double size, // Recebe o tamanho calculado
  }) {
    final statusColor = isOk ? Colors.green : Colors.red;
    final statusEmoji = isOk ? '✅' : '❌';
    final statusText = isOk ? 'OK' : 'ALERTA';

    return SizedBox(
      width: size,
      height: size, // Garante que a altura seja igual à largura
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(statusEmoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
