// models/zone_model.dart
class CityZones {
  final String city;
  final String note;
  final List<Zone> zones;
  final List<String> importantNotesForBeginners;

  CityZones({
    required this.city,
    required this.note,
    required this.zones,
    required this.importantNotesForBeginners,
  });

  factory CityZones.fromJson(Map<String, dynamic> json) {
    return CityZones(
      city: json['city'] ?? '',
      note: json['note'] ?? '',
      zones: (json['zones'] as List? ?? [])
          .map((zone) => Zone.fromJson(zone))
          .toList(),
      importantNotesForBeginners: List<String>.from(
          json['importantNotesForBeginners'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'note': note,
      'zones': zones.map((zone) => zone.toJson()).toList(),
      'importantNotesForBeginners': importantNotesForBeginners,
    };
  }
}

class Zone {
  final String zoneId;
  final String zoneName;
  final String description;
  final List<String> includedAreas;
  final CenterPoint centerPoint;
  final int radiusKm;
  final String radiusExplanation;
  final String example;

  Zone({
    required this.zoneId,
    required this.zoneName,
    required this.description,
    required this.includedAreas,
    required this.centerPoint,
    required this.radiusKm,
    required this.radiusExplanation,
    required this.example,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      zoneId: json['zoneId'] ?? '',
      zoneName: json['zoneName'] ?? '',
      description: json['description'] ?? '',
      includedAreas: List<String>.from(json['includedAreas'] ?? []),
      centerPoint: CenterPoint.fromJson(json['centerPoint'] ?? {}),
      radiusKm: json['radiusKm'] ?? 0,
      radiusExplanation: json['radiusExplanation'] ?? '',
      example: json['example'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zoneId': zoneId,
      'zoneName': zoneName,
      'description': description,
      'includedAreas': includedAreas,
      'centerPoint': centerPoint.toJson(),
      'radiusKm': radiusKm,
      'radiusExplanation': radiusExplanation,
      'example': example,
    };
  }

  @override
  String toString() {
    return '$zoneName (${includedAreas.length} areas)';
  }

  String get shortInfo {
    return '$zoneName - ${includedAreas.length} areas, ${radiusKm}km radius';
  }
}

class CenterPoint {
  final double latitude;
  final double longitude;
  final String explanation;

  CenterPoint({
    required this.latitude,
    required this.longitude,
    required this.explanation,
  });

  factory CenterPoint.fromJson(Map<String, dynamic> json) {
    return CenterPoint(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'explanation': explanation,
    };
  }
}