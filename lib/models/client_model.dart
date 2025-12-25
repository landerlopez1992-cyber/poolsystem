class ClientModel {
  final String id;
  final String companyId;
  final String fullName;
  final String? email;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? poolType; // residential, commercial, etc.
  final String? poolSize;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // active, inactive

  ClientModel({
    required this.id,
    required this.companyId,
    required this.fullName,
    this.email,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.poolType,
    this.poolSize,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'active',
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      poolType: json['pool_type'] as String?,
      poolSize: json['pool_size'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'pool_type': poolType,
      'pool_size': poolSize,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
    };
  }
}

