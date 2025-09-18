import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sync_viewmodel.dart';
import 'log_viewer_view.dart';

class SyncProgressView extends StatefulWidget {
  const SyncProgressView({super.key});

  @override
  State<SyncProgressView> createState() => _SyncProgressViewState();
}

class _SyncProgressViewState extends State<SyncProgressView> {
  late SyncViewModel _viewModel;
  bool _syncFinishedHandled = false;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<SyncViewModel>();
    _viewModel.addListener(_onViewModelUpdate);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdate);
    super.dispose();
  }

  void _onViewModelUpdate() async {
    // GUARDA: Se a operação foi cancelada, não fazemos nada aqui.
    // A navegação já foi tratada pelo _showCancelDialog.
    if (_viewModel.wasCancelled) {
      return;
    }

    if (!_viewModel.isSyncing && !_syncFinishedHandled) {
      setState(() {
        _syncFinishedHandled = true;
      });
      if (_viewModel.recordsReceived > 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LogViewerView(logs: _viewModel.syncedData),
          ),
        );
      } else {
        await _showNoRecordsFoundDialog();
        if (mounted) {
          Navigator.of(context).popUntil(ModalRoute.withName('/scanner'));
        }
      }
    }
  }

  Future<void> _showNoRecordsFoundDialog() async {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Sincronização Concluída"),
          content: const SingleChildScrollView(
            child: Text("Nenhum registo novo foi encontrado."),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCancelDialog() async {
    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text("Cancelar Sincronização?"),
            content: const Text("Deseja interromper a transferência de dados?"),
            actions: [
              TextButton(
                child: const Text("Não"),
                onPressed: () => Navigator.pop(dialogContext, false),
              ),
              TextButton(
                child: const Text("Sim, Cancelar"),
                onPressed: () => Navigator.pop(dialogContext, true),
              ),
            ],
          ),
    );

    if (shouldCancel == true && mounted) {
      // 1. Envia o comando para o ESP32 parar
      _viewModel.cancelSync();

      // 2. Volta duas telas para chegar na DeviceActionsView
      // O primeiro pop fecha a SyncProgressView
      Navigator.of(context).pop();
      // O segundo pop fecha a SyncOptionsView
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SyncViewModel>();
    return PopScope(
      canPop: !viewModel.isSyncing,
      onPopInvokedWithResult: (bool didPop, dynamic _) {
        if (didPop) return;
        _showCancelDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sincronizando..."),
          automaticallyImplyLeading: !viewModel.isSyncing,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: viewModel.syncProgress,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    Text(
                      "${(viewModel.syncProgress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "Recebendo registros...",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  "${viewModel.recordsReceived} de ${viewModel.totalRecordsToReceive}",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
