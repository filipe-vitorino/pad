import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/sensor_data.dart';
import 'log_viewer_view.dart';

class ReadingHistoryView extends StatefulWidget {
  const ReadingHistoryView({super.key});
  @override
  _ReadingHistoryViewState createState() => _ReadingHistoryViewState();
}

class _ReadingHistoryViewState extends State<ReadingHistoryView> {
  late Future<List<Map<String, dynamic>>> _readingsFuture;

  @override
  void initState() {
    super.initState();
    _readingsFuture = DatabaseService.instance.getReadingsSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Histórico de Leituras")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _readingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Nenhuma leitura salva encontrada."),
            );
          }

          final readings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: readings.length,
            itemBuilder: (context, index) {
              final reading = readings[index];
              final dateTime = DateTime.fromMillisecondsSinceEpoch(
                reading['dataLeitura'],
              );
              final formattedDate = DateFormat(
                'dd/MM/yyyy \'às\' HH:mm',
              ).format(dateTime);
              final deviceId = reading['deviceId'] ?? 'ID Desconhecido';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(reading['id'].toString())),
                  title: Text("Leitura #${reading['id']}"),

                  subtitle: Text(
                    "Aparelho: $deviceId\nFeita em $formattedDate • ${reading['totalRegistos']} registos",
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  isThreeLine: true,
                  onTap: () async {
                    // Busca os registos detalhados e navega para a tela de visualização
                    final List<SensorData> logs = await DatabaseService.instance
                        .getLogsForReading(reading['id']);
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LogViewerView(logs: logs),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
