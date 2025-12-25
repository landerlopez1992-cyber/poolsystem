import 'supabase_service.dart';
import '../models/ticket_message_model.dart';

class TicketMessageService {
  final _supabase = SupabaseService.client;

  // Enviar mensaje en un ticket
  Future<TicketMessageModel> sendMessage({
    required String ticketId,
    required String senderId,
    required String message,
  }) async {
    try {
      // Obtener información del remitente
      final senderData = await _supabase
          .from('users')
          .select('full_name, role')
          .eq('id', senderId)
          .single();

      final response = await _supabase
          .from('ticket_messages')
          .insert({
            'ticket_id': ticketId,
            'sender_id': senderId,
            'message': message,
            'is_read': false,
          })
          .select()
          .single();

      // Agregar información del remitente
      final messageJson = Map<String, dynamic>.from(response);
      messageJson['sender_name'] = senderData['full_name'] as String?;
      messageJson['sender_role'] = senderData['role'] as String?;

      return TicketMessageModel.fromJson(messageJson);
    } catch (e) {
      throw Exception('Error al enviar mensaje: $e');
    }
  }

  // Obtener todos los mensajes de un ticket
  Future<List<TicketMessageModel>> getTicketMessages(String ticketId) async {
    try {
      final response = await _supabase
          .from('ticket_messages')
          .select('''
            *,
            users:sender_id (
              full_name,
              role
            )
          ''')
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      return (response as List).map((json) {
        final messageJson = Map<String, dynamic>.from(json);
        if (json['users'] != null) {
          final user = json['users'] as Map<String, dynamic>;
          messageJson['sender_name'] = user['full_name'] as String?;
          messageJson['sender_role'] = user['role'] as String?;
        }
        return TicketMessageModel.fromJson(messageJson);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener mensajes: $e');
    }
  }

  // Marcar mensajes como leídos
  Future<void> markMessagesAsRead(String ticketId, String userId) async {
    try {
      await _supabase
          .from('ticket_messages')
          .update({'is_read': true})
          .eq('ticket_id', ticketId)
          .neq('sender_id', userId); // No marcar como leídos los propios mensajes
    } catch (e) {
      throw Exception('Error al marcar mensajes como leídos: $e');
    }
  }

  // Suscribirse a nuevos mensajes en tiempo real
  Stream<List<TicketMessageModel>> subscribeToMessages(String ticketId) {
    return _supabase
        .from('ticket_messages')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId)
        .order('created_at')
        .map((data) {
      return data.map((json) {
        // Necesitamos obtener información del usuario para cada mensaje
        // Por ahora retornamos sin nombre, se puede mejorar con una consulta adicional
        return TicketMessageModel.fromJson(json);
      }).toList();
    });
  }
}

