class ScheduleModel {
  final String id;
  final String companyId;
  final String workerId;
  final DateTime date;
  final DateTime startTime;
  final DateTime? endTime;
  final String? title;
  final String? description;
  final String type; // route, maintenance, training, meeting, etc.
  final String? relatedId; // ID de ruta, mantenimiento, etc.
  final String status; // scheduled, in_progress, completed, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  ScheduleModel({
    required this.id,
    required this.companyId,
    required this.workerId,
    required this.date,
    required this.startTime,
    this.endTime,
    this.title,
    this.description,
    required this.type,
    this.relatedId,
    this.status = 'scheduled',
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      workerId: json['worker_id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time'] as String) : null,
      title: json['title'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String,
      relatedId: json['related_id'] as String?,
      status: json['status'] as String? ?? 'scheduled',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'worker_id': workerId,
      'date': date.toIso8601String(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'title': title,
      'description': description,
      'type': type,
      'related_id': relatedId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

