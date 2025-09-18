import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/wifi_sync_viewmodel.dart';
import 'log_viewer_view.dart';

class WifiSyncProgressView extends StatelessWidget {
  const WifiSyncProgressView({super.key});

  Future<void> _showNoRecordsFoundDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text("Sincronização Concluída"),
            content: const Text("Nenhum registo novo foi encontrado."),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WifiSyncViewModel>(
      builder: (context, viewModel, child) {
        // --- LÓGICA DE NAVEGAÇÃO SEGURA ---
        // Se a sincronização terminou...
        if (!viewModel.isSyncing) {
          // Agenda a ação para DEPOIS da fase de construção da UI
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!context.mounted) return;

            // Se houve um erro, simplesmente volta
            if (viewModel.errorMessage.isNotEmpty) {
              Navigator.pop(context);
              return;
            }

            // Se foi bem-sucedido e há dados, avança para os resultados
            if (viewModel.syncedLogs.isNotEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LogViewerView(logs: viewModel.syncedLogs),
                ),
              );
            }
            // Se foi bem-sucedido mas não há dados, mostra o diálogo e volta
            else {
              await _showNoRecordsFoundDialog(context);
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          });
        }

        return PopScope(
          canPop: !viewModel.isSyncing,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("A Sincronizar via Wi-Fi..."),
              automaticallyImplyLeading: !viewModel.isSyncing,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 32),
                    Text(
                      "A transferir dados...",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${viewModel.recordsDownloaded} registos recebidos",
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    if (viewModel.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Text(
                          viewModel.errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
