import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:app_settings/app_settings.dart';
import '../viewmodels/wifi_scanner_viewmodel.dart';
import 'wifi_actions_view.dart';

class WifiScannerView extends StatefulWidget {
  const WifiScannerView({super.key});

  @override
  State<WifiScannerView> createState() => _WifiScannerViewState();
}

class _WifiScannerViewState extends State<WifiScannerView> {
  Timer? _checkConnectionTimer;

  @override
  void dispose() {
    _stopConnectionChecker();
    super.dispose();
  }

  void _startConnectionChecker(String targetSsidPrefix) {
    _stopConnectionChecker();

    _checkConnectionTimer = Timer.periodic(const Duration(seconds: 2), (
      timer,
    ) async {
      String? currentSsid = await WiFiForIoTPlugin.getSSID();
      print(
        "Verificando Wi-Fi... Conectado a: '$currentSsid' | Alvo começa com: '$targetSsidPrefix'",
      );

      // --- ALTERAÇÃO AQUI: de '==' para 'startsWith' ---
      if (currentSsid != null && currentSsid.startsWith(targetSsidPrefix)) {
        print("✅ Conexão por prefixo detetada! A navegar...");
        _stopConnectionChecker();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              // Passamos o nome real da rede à qual nos conectámos
              builder: (context) => WifiActionsView(deviceName: currentSsid),
            ),
          );
        }
      }
    });
  }

  void _stopConnectionChecker() {
    _checkConnectionTimer?.cancel();
    _checkConnectionTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WifiScannerViewModel(),
      child: Consumer<WifiScannerViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Selecione o Servidor Wi-Fi'),
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
                          () =>
                              _showManualConnectionDialog(context, result.ssid),
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

  Future<void> _showManualConnectionDialog(
    BuildContext context,
    String targetSsid,
  ) async {
    return showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Conectar à Rede'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Você será direcionado para as configurações de Wi-Fi.",
                ),
                const SizedBox(height: 16),
                const Text(
                  "1. Conecte-se a uma rede que comece com:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(targetSsid),
                const SizedBox(height: 8),
                const Text(
                  "2. Volte para este aplicativo.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text("A navegação será automática."),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                child: const Text('ABRIR CONFIG. WI-FI'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _startConnectionChecker(targetSsid);
                  AppSettings.openAppSettings(type: AppSettingsType.wifi);
                },
              ),
            ],
          ),
    );
  }
}
