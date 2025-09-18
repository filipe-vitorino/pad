import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pacote para formatação de data
import '../models/sensor_data.dart';

class LogViewerView extends StatelessWidget {
  final List<SensorData> logs;
  const LogViewerView({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    // Ordena os logs do mais recente para o mais antigo para melhor visualização
    final sortedLogs = List<SensorData>.from(logs)
      ..sort((a, b) => (b.ts ?? 0).compareTo(a.ts ?? 0));

    return Scaffold(
      appBar: AppBar(title: Text("Histórico (${sortedLogs.length} Registos)")),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: sortedLogs.length,
        itemBuilder: (context, index) {
          final log = sortedLogs[index];

          // Formata o timestamp Unix (em segundos) para uma data/hora legível
          final dateTime = DateTime.fromMillisecondsSinceEpoch(
            (log.ts ?? 0) * 1000,
          );
          final formattedDate = DateFormat(
            'dd/MM/yyyy HH:mm:ss',
          ).format(dateTime);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 16.0,
              ),
              leading: CircleAvatar(
                child: Text(
                  (sortedLogs.length - index).toString(),
                ), // Contagem decrescente
              ),
              title: Text(
                formattedDate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              // O subtítulo agora é uma Coluna para organizar todos os dados
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Usamos uma função auxiliar para criar cada linha de dados
                    _buildSensorRow(
                      context,
                      Icons.waves,
                      "Vazão:",
                      "${log.vazao?.toStringAsFixed(2) ?? '--'} L/min",
                      Colors.blue.shade600,
                    ),
                    const SizedBox(height: 6),
                    _buildSensorRow(
                      context,
                      Icons.opacity,
                      "Volume:",
                      "${log.volume?.toStringAsFixed(2) ?? '--'} L",
                      Colors.cyan.shade600,
                    ),
                    const SizedBox(height: 6),
                    _buildSensorRow(
                      context,
                      Icons.compress,
                      "Pressão:",
                      "${log.pressao?.toStringAsFixed(2) ?? '--'} bar",
                      Colors.orange.shade700,
                    ),
                    const SizedBox(height: 6),
                    _buildSensorRow(
                      context,
                      Icons.thermostat,
                      "Temperatura:",
                      "${log.temperatura?.toStringAsFixed(1) ?? '--'} °C",
                      Colors.red.shade600,
                    ),
                    const SizedBox(height: 6),
                    _buildSensorRow(
                      context,
                      Icons.science_outlined,
                      "TDS:",
                      "${log.tds?.toStringAsFixed(1) ?? '--'} ppm",
                      Colors.purple.shade500,
                    ),
                  ],
                ),
              ),

              // O trailing agora é um ícone de status de sincronização com a nuvem
              trailing: Tooltip(
                message:
                    log.enviadoServidor
                        ? 'Enviado para o servidor'
                        : 'Pendente de envio',
                child: Icon(
                  log.enviadoServidor
                      ? Icons.cloud_done
                      : Icons.cloud_upload_outlined,
                  color: log.enviadoServidor ? Colors.green : Colors.orange,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget auxiliar para criar uma linha de dado de sensor com ícone,
  /// rótulo e valor, para evitar repetição de código.
  Widget _buildSensorRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
