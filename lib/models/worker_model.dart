class WorkerModel {
  final String id;
  final String companyId;
  final String userId; // Referencia a users table
  final String fullName;
  final String? phone;
  final String? email;
  final String? specialization; // limpieza, mantenimiento, químico, etc.
  final String? licenseNumber;
  final DateTime? hireDate;
  final String status; // active, inactive, on_route
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime? lastLocationUpdate;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkerModel({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.fullName,
    this.phone,
    this.email,
    this.specialization,
    this.licenseNumber,
    this.hireDate,
    this.status = 'active',
    this.currentLatitude,
    this.currentLongitude,
    this.lastLocationUpdate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      specialization: json['specialization'] as String?,
      licenseNumber: json['license_number'] as String?,
      hireDate: json['hire_date'] != null ? DateTime.parse(json['hire_date'] as String) : null,
      status: json['status'] as String? ?? 'active',
      currentLatitude: json['current_latitude'] != null ? (json['current_latitude'] as num).toDouble() : null,
      currentLongitude: json['current_longitude'] != null ? (json['current_longitude'] as num).toDouble() : null,
      lastLocationUpdate: json['last_location_update'] != null ? DateTime.parse(json['last_location_update'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'specialization': specialization,
      'license_number': licenseNumber,
      'hire_date': hireDate?.toIso8601String(),
      'status': status,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'last_location_update': lastLocationUpdate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

