import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../viewmodels/scanner_viewmodel.dart';
import '../services/ble_service.dart';
import 'device_actions_view.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});
  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  @override
  void initState() {
    super.initState();
    context.read<ScannerViewModel>().init();
  }

  /// Inicia a conexão, mostra o progresso e navega se for bem-sucedido.
  Future<void> _connectAndNavigate(BluetoothDevice device) async {
    final bleService = BleService();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("A conectar..."),
              ],
            ),
          ),
    );

    final bool success = await bleService.connectToDevice(device);
    if (mounted) Navigator.pop(context);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          // Navega para a tela de ações sem passar o device, pois a conexão é global
          builder: (context) => const DeviceActionsView(),
          settings: const RouteSettings(name: '/scanner'),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao conectar ao dispositivo."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ScannerViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione um Dispositivo BLE'),
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
                  _connectAndNavigate(result.device);
                },
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
  }
}
