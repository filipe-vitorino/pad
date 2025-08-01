/*
 * Título: View do Scanner Wi-Fi (com Lógica de Navegação Corrigida)
 * Descrição: Interface para escanear e conectar a um ESP32 via Wi-Fi.
 * Lógica de navegação após conexão corrigida.
 * Autor: Gemini
 * Data: 01 de Agosto de 2025
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../viewmodels/wifi_scanner_viewmodel.dart';
import 'http_controller_view.dart';

class WifiScannerView extends StatelessWidget {
  const WifiScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WifiScannerViewModel(),
      child: Consumer<WifiScannerViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Selecione o Servidor ESP32'),
              actions: [
                if (viewModel.isScanning)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: viewModel.startScan,
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
                        Icons.wifi_tethering,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(result.ssid),
                      subtitle: Text("Sinal: ${result.level} dBm"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap:
                          () => _showPasswordDialog(context, result, viewModel),
                    ),
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: viewModel.startScan,
              child: const Icon(Icons.refresh),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showPasswordDialog(
    BuildContext context,
    WiFiAccessPoint ap,
    WifiScannerViewModel viewModel,
  ) async {
    final passwordController = TextEditingController();
    bool isPasswordObscured = true;

    // O context do diálogo é diferente do context da tela principal.
    // Vamos guardar uma referência ao context do diálogo para fechá-lo.
    BuildContext? dialogContext;

    await showDialog(
      context: context,
      builder: (dContext) {
        dialogContext = dContext; // Armazena o context do diálogo
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Conectar a ${ap.ssid}'),
              content: TextField(
                controller: passwordController,
                obscureText: isPasswordObscured,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setStateDialog(() {
                        isPasswordObscured = !isPasswordObscured;
                      });
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  // ================= LÓGICA CORRIGIDA AQUI =================
                  onPressed: () async {
                    // 1. Pega a senha
                    final password = passwordController.text;

                    // 2. Tenta conectar e ESPERA pelo resultado
                    final success = await viewModel.connectToWifi(
                      ap.ssid,
                      password,
                    );

                    // 3. AGORA, com o resultado em mãos, decide o que fazer
                    if (success && context.mounted) {
                      // 4. Se deu certo, FECHA o diálogo...
                      Navigator.pop(dialogContext!);

                      // 5. ... e NAVEGA para a próxima tela.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  HttpControllerView(deviceName: ap.ssid),
                        ),
                      );
                    } else if (context.mounted) {
                      // Se falhou, podemos mostrar um erro aqui dentro do diálogo
                      // ou simplesmente fechar o diálogo e mostrar um SnackBar.
                      // Por enquanto, vamos manter o comportamento de fechar e mostrar o SnackBar.
                      Navigator.pop(dialogContext!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Falha ao conectar a ${ap.ssid}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  // ========================================================
                  child: const Text('Conectar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
