class SensorData {
  final int? id; // O ID do registo no banco de dados local
  final bool enviadoServidor;
  final int? ts;
  final double? vazao;
  final double? volume;
  final double? pressao;
  final double? temperatura;
  final double? tds;

  SensorData({
    this.id,
    this.enviadoServidor = false,
    this.ts,
    this.vazao,
    this.volume,
    this.pressao,
    this.temperatura,
    this.tds,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'] as int?,
      enviadoServidor: (json['enviadoServidor'] as int? ?? 0) == 1,
      ts: (json['ts'] as num?)?.toInt(),
      vazao: (json['vazao'] as num?)?.toDouble(),
      volume: (json['volume'] as num?)?.toDouble(),
      pressao: (json['pressao'] as num?)?.toDouble(),
      temperatura: (json['temperatura'] as num?)?.toDouble(),
      tds: (json['tds'] as num?)?.toDouble(),
    );
  }
}
