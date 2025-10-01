
class MPTracking {
  final String kurir;
  final String resi;
  final String status;
  final List<MPTrackingManifest> manifests;

  MPTracking({required this.kurir, required this.resi, required this.status, required this.manifests});

  factory MPTracking.fromJson(dynamic json) {
    return MPTracking(
      kurir: json['courier_name'],
      resi: json['waybill_number'],
      status: json['status'],
      manifests: (json['manifest'] as List<dynamic>)
          .map((e) => MPTrackingManifest.fromJson(e))
          .toList(),
    );
  }
}

class MPTrackingManifest {
  final String description;
  final String timestamp;

  MPTrackingManifest({required this.description, required this.timestamp});

  factory MPTrackingManifest.fromJson(dynamic json) {
    return MPTrackingManifest(
      description: json['description'],
      timestamp: json['timestamp'],
    );
  }
}
