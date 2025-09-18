import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../services/wifi_http_service.dart';

class WifiScannerViewModel extends ChangeNotifier {
  final WifiHttpService _wifiService = WifiHttpService();

  List<WiFiAccessPoint> get scanResults => _wifiService.scanResults.value;
  bool get isScanning => _wifiService.isScanning.value;

  WifiScannerViewModel() {
    _wifiService.scanResults.addListener(notifyListeners);
    _wifiService.isScanning.addListener(notifyListeners);
    _initialize();
  }

  Future<void> _initialize() async {
    await _wifiService.requestPermissions();
    await startScan();
  }

  Future<void> startScan() async => await _wifiService.startScan();

  Future<bool> connectToWifi(String ssid, String password) async {
    try {
      await WiFiForIoTPlugin.disconnect();
      return await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        security: NetworkSecurity.WPA,
        joinOnce: true,
      );
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _wifiService.scanResults.removeListener(notifyListeners);
    _wifiService.isScanning.removeListener(notifyListeners);
    super.dispose();
  }
}
