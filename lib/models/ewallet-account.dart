// @dart=2.9

class EwalletAccount {
  final String name;
  final String code;
  final String description;
  final String provider;
  final double fee; // Changed from int to double to handle decimal values

  EwalletAccount(
      {this.name, this.code, this.description, this.provider, this.fee});

  factory EwalletAccount.fromJson(dynamic json) {
    try {
      // Handle admin fee parsing with better error handling
      double adminFee = 0.0;
      if (json['admin'] != null && json['admin'] is Map) {
        var admin = json['admin'];
        if (admin['nominal'] != null) {
          // Convert to double safely
          if (admin['nominal'] is int) {
            adminFee = (admin['nominal'] as int).toDouble();
          } else if (admin['nominal'] is double) {
            adminFee = admin['nominal'] as double;
          } else if (admin['nominal'] is String) {
            adminFee = double.tryParse(admin['nominal']) ?? 0.0;
          }
        }
      }

      return EwalletAccount(
        name: json['ewallet_name'] ?? '',
        code: json['ewallet_code'] ?? '',
        description: json['desc'] ?? '',
        provider: json['provider'] ?? '',
        fee: adminFee,
      );
    } catch (e) {
      print('ERROR: Failed to parse EwalletAccount: $e');
      print('ERROR: JSON data: $json');
      // Return default values if parsing fails
      return EwalletAccount(
        name: json['ewallet_name'] ?? 'Unknown',
        code: json['ewallet_code'] ?? '',
        description: json['desc'] ?? 'Error parsing data',
        provider: json['provider'] ?? '',
        fee: 0.0,
      );
    }
  }

  @override
  String toString() {
    return 'EwalletAccount(name: $name, code: $code, fee: $fee)';
  }
}
