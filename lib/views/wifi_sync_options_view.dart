import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/wifi_sync_viewmodel.dart';
import 'wifi_sync_progress_view.dart';

class WifiSyncOptionsView extends StatelessWidget {
  final String deviceName;
  const WifiSyncOptionsView({super.key, required this.deviceName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WifiSyncViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Coletar Dados via Wi-Fi")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Consumer<WifiSyncViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.wifi_protected_setup,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Sincronizar Histórico",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Todos os registos do aparelho serão transferidos via Wi-Fi e depois apagados do dispositivo. Este processo pode demorar um pouco.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),

                    if (viewModel.isSyncing)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cloud_download),
                        label: const Text("Iniciar Sincronização"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () {
                          // Inicia o processo de busca em segundo plano
                          viewModel.syncAllData();

                          // Navega para a tela de progresso para mostrar o andamento
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ChangeNotifierProvider.value(
                                    value:
                                        viewModel, // Passa a mesma instância do ViewModel
                                    child: const WifiSyncProgressView(),
                                  ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
