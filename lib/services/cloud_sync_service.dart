import '../services/database_service.dart';
import '../models/sensor_data.dart';

class CloudSyncService {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<bool> syncDataToServer() async {
    print("☁️ Iniciando sincronização com o servidor...");

    // 1. Busca os dados não sincronizados do banco de dados local
    final List<SensorData> unsyncedLogs = await _dbService.getUnsyncedLogs();

    if (unsyncedLogs.isEmpty) {
      print("☁️ Nenhum dado novo para sincronizar.");
      return true; // Sucesso, pois não havia nada a fazer
    }

    print("☁️ Encontrados ${unsyncedLogs.length} registos para enviar.");

    try {
      // 2. AQUI: A LÓGICA DE ENVIO PARA O SERVIDOR REAL
      // Você iria converter 'unsyncedLogs' para um JSON e enviar via HTTP POST
      // para a sua API, por exemplo.
      //
      // vamos simular uma chamada de rede bem-sucedida:
      await Future.delayed(const Duration(seconds: 3));
      print("☁️ SIMULAÇÃO: API respondeu com sucesso.");
      // Fim da simulação.

      // 3. Se o envio foi bem-sucedido, pega os IDs dos registos enviados
      final List<int> syncedIds = unsyncedLogs.map((log) => log.id!).toList();

      // 4. Marca estes registos como "sincronizados" no banco de dados local
      await _dbService.markLogsAsSynced(syncedIds);

      print("☁️ Sincronização concluída com sucesso!");
      return true;
    } catch (e) {
      print("☁️ ERRO: Falha ao sincronizar com o servidor: $e");
      return false;
    }
  }
}
