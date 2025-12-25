class TicketMessageModel {
  final String id;
  final String ticketId;
  final String senderId;
  final String? senderName;
  final String? senderRole; // 'super_admin', 'admin'
  final String message;
  final DateTime createdAt;
  final bool isRead;

  TicketMessageModel({
    required this.id,
    required this.ticketId,
    required this.senderId,
    this.senderName,
    this.senderRole,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    return TicketMessageModel(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String?,
      senderRole: json['sender_role'] as String?,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  bool get isFromSuperAdmin => senderRole == 'super_admin';
  bool get isFromCompany => senderRole == 'admin';
}

