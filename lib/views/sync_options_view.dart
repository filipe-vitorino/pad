import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../viewmodels/sync_viewmodel.dart';
import 'sync_progress_view.dart';

class SyncOptionsView extends StatefulWidget {
  // Construtor sem 'device'
  const SyncOptionsView({super.key});

  @override
  State<SyncOptionsView> createState() => _SyncOptionsViewState();
}

class _SyncOptionsViewState extends State<SyncOptionsView> {
  bool _isInitializing = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SyncViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Coletar Dados")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Consumer<SyncViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.connectionState !=
                    BluetoothConnectionState.connected) {
                  // Este feedback é importante se a conexão cair enquanto o utilizador está nesta tela
                  return const Center(
                    child: Text(
                      "Conexão perdida. Por favor, volte e tente novamente.",
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.history_edu,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Recuperar Histórico",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Todos os registos do aparelho serão transferidos e depois apagados.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),

                    _isInitializing
                        ? const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text("Buscando configuração..."),
                            ],
                          ),
                        )
                        : ElevatedButton.icon(
                          icon: const Icon(Icons.cloud_download),
                          label: const Text("Iniciar Sincronização"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          onPressed: () async {
                            setState(() => _isInitializing = true);

                            // Chama o método que busca a config e depois os logs
                            bool isReady = await viewModel.initializeSync();

                            setState(() => _isInitializing = false);

                            if (isReady && mounted) {
                              // Navega para a tela de progresso
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ChangeNotifierProvider.value(
                                        value: viewModel,
                                        child: const SyncProgressView(),
                                      ),
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Falha ao obter configuração do dispositivo.",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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
