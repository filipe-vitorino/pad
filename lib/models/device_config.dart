// Modelo para os limites de um sensor específico
class SensorThreshold {
  final double? min;
  final double? max;

  SensorThreshold({this.min, this.max});

  factory SensorThreshold.fromJson(Map<String, dynamic> json) {
    return SensorThreshold(
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
    );
  }
}

// Modelo para as coordenadas GPS
class GpsPosition {
  final double? latitude;
  final double? longitude;

  GpsPosition({this.latitude, this.longitude});

  factory GpsPosition.fromJson(Map<String, dynamic> json) {
    return GpsPosition(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

// Modelo principal da configuração
class DeviceConfig {
  final String deviceId;
  final GpsPosition gps;
  final Map<String, SensorThreshold> thresholds;

  DeviceConfig({
    required this.deviceId,
    required this.gps,
    required this.thresholds,
  });

  factory DeviceConfig.fromJson(Map<String, dynamic> json) {
    var thresholdsMap = <String, SensorThreshold>{};
    if (json['thresholds'] is Map) {
      (json['thresholds'] as Map<String, dynamic>).forEach((key, value) {
        thresholdsMap[key] = SensorThreshold.fromJson(value);
      });
    }

    return DeviceConfig(
      deviceId: json['deviceId'] ?? 'ID Desconhecido',
      gps: GpsPosition.fromJson(json['gps'] ?? {}),
      thresholds: thresholdsMap,
    );
  }
}
