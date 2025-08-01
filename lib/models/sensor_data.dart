class SensorData {
  final double? vazao;
  final double? volume;
  final double? pressao;
  final double? temperatura;
  final double? tds;

  SensorData({
    this.vazao,
    this.volume,
    this.pressao,
    this.temperatura,
    this.tds,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      vazao: (json['vazao'] as num?)?.toDouble(),
      volume: (json['volume'] as num?)?.toDouble(),
      pressao: (json['pressao'] as num?)?.toDouble(),
      temperatura: (json['temperatura'] as num?)?.toDouble(),
      tds: (json['tds'] as num?)?.toDouble(),
    );
  }
}
