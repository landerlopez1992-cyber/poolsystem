class MaintenanceModel {
  final String id;
  final String companyId;
  final String clientId;
  final String? routeId;
  final String? workerId;
  final String type; // limpieza, químico, reparación, inspección, etc.
  final String? description;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String status; // pending, in_progress, completed, cancelled
  final String? notes;
  final List<String>? photos; // URLs de fotos
  final double? cost;
  final int? durationMinutes;
  final Map<String, dynamic>? checklist; // Checklist de tareas
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceModel({
    required this.id,
    required this.companyId,
    required this.clientId,
    this.routeId,
    this.workerId,
    required this.type,
    this.description,
    required this.scheduledDate,
    this.completedDate,
    this.status = 'pending',
    this.notes,
    this.photos,
    this.cost,
    this.durationMinutes,
    this.checklist,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      clientId: json['client_id'] as String,
      routeId: json['route_id'] as String?,
      workerId: json['worker_id'] as String?,
      type: json['type'] as String,
      description: json['description'] as String?,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      completedDate: json['completed_date'] != null ? DateTime.parse(json['completed_date'] as String) : null,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      photos: json['photos'] != null ? List<String>.from(json['photos'] as List) : null,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      durationMinutes: json['duration_minutes'] as int?,
      checklist: json['checklist'] != null ? Map<String, dynamic>.from(json['checklist'] as Map) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'client_id': clientId,
      'route_id': routeId,
      'worker_id': workerId,
      'type': type,
      'description': description,
      'scheduled_date': scheduledDate.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'photos': photos,
      'cost': cost,
      'duration_minutes': durationMinutes,
      'checklist': checklist,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

