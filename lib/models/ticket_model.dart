class TicketModel {
  final String id;
  final String companyId;
  final String? companyName;
  final String subject;
  final String description;
  final String status; // 'open', 'in_progress', 'closed'
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final String createdBy; // Super Admin user ID
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? closedAt;
  final String? closedBy;

  TicketModel({
    required this.id,
    required this.companyId,
    this.companyName,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.closedAt,
    this.closedBy,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      companyName: json['company_name'] as String?,
      subject: json['subject'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      closedBy: json['closed_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'company_name': companyName,
      'subject': subject,
      'description': description,
      'status': status,
      'priority': priority,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'closed_by': closedBy,
    };
  }

  TicketModel copyWith({
    String? id,
    String? companyId,
    String? companyName,
    String? subject,
    String? description,
    String? status,
    String? priority,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
    String? closedBy,
  }) {
    return TicketModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: closedAt ?? this.closedAt,
      closedBy: closedBy ?? this.closedBy,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'open':
        return 'Abierto';
      case 'in_progress':
        return 'En Progreso';
      case 'closed':
        return 'Cerrado';
      default:
        return status;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'low':
        return 'Baja';
      case 'medium':
        return 'Media';
      case 'high':
        return 'Alta';
      case 'urgent':
        return 'Urgente';
      default:
        return priority;
    }
  }

  // Color según prioridad
  int get priorityColor {
    switch (priority) {
      case 'low':
        return 0xFF4CAF50; // Verde
      case 'medium':
        return 0xFFFF9800; // Naranja
      case 'high':
        return 0xFFFF5722; // Naranja oscuro
      case 'urgent':
        return 0xFFDC2626; // Rojo
      default:
        return 0xFF666666; // Gris
    }
  }

  // Color según estado
  int get statusColor {
    switch (status) {
      case 'open':
        return 0xFF2196F3; // Azul
      case 'in_progress':
        return 0xFFFF9800; // Naranja
      case 'closed':
        return 0xFF4CAF50; // Verde
      default:
        return 0xFF666666; // Gris
    }
  }
}

