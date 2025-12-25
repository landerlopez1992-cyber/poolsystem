class RouteModel {
  final String id;
  final String companyId;
  final String workerId;
  final String name;
  final String? description;
  final DateTime scheduledDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status; // scheduled, in_progress, completed
  final List<String> clientIds; // IDs de clientes en la ruta
  final int? totalClients;
  final int? completedClients;
  final double? totalDistance;
  final DateTime createdAt;
  final DateTime updatedAt;

  RouteModel({
    required this.id,
    required this.companyId,
    required this.workerId,
    required this.name,
    this.description,
    required this.scheduledDate,
    this.startDate,
    this.endDate,
    this.status = 'scheduled',
    required this.clientIds,
    this.totalClients,
    this.completedClients,
    this.totalDistance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      workerId: json['worker_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      status: json['status'] as String? ?? 'scheduled',
      clientIds: json['client_ids'] != null ? List<String>.from(json['client_ids'] as List) : [],
      totalClients: json['total_clients'] as int?,
      completedClients: json['completed_clients'] as int?,
      totalDistance: json['total_distance'] != null ? (json['total_distance'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'worker_id': workerId,
      'name': name,
      'description': description,
      'scheduled_date': scheduledDate.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'client_ids': clientIds,
      'total_clients': totalClients,
      'completed_clients': completedClients,
      'total_distance': totalDistance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

