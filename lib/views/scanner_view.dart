/*
 * Título: View da Tela de Scanner
 * Descrição: Interface gráfica para exibir dispositivos BLE encontrados.
 * Autor: Gemini
 * Data: 01 de Agosto de 2025
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/scanner_viewmodel.dart';
import 'controller_view.dart';

class ScannerView extends StatelessWidget {
  const ScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    // Usa o Consumer para reconstruir o widget quando o ViewModel notificar mudanças
    return Consumer<ScannerViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Selecione um Dispositivo'),
            actions: [
              if (viewModel.isScanning)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => viewModel.startScan(),
            child: ListView.builder(
              itemCount: viewModel.scanResults.length,
              itemBuilder: (context, index) {
                final result = viewModel.scanResults[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.memory,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      result.device.platformName.isNotEmpty
                          ? result.device.platformName
                          : "Dispositivo Desconhecido",
                    ),
                    subtitle: Text("Sinal: ${result.rssi} dBm"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      viewModel.stopScan();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ControllerView(device: result.device),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: viewModel.startScan,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }
}
