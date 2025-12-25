import 'supabase_service.dart';
import '../models/ticket_model.dart';

class TicketService {
  final _supabase = SupabaseService.client;

  // Crear nuevo ticket
  Future<TicketModel> createTicket({
    required String companyId,
    required String subject,
    required String description,
    required String priority,
    required String createdBy,
  }) async {
    try {
      final response = await _supabase
          .from('support_tickets')
          .insert({
            'company_id': companyId,
            'subject': subject,
            'description': description,
            'status': 'open',
            'priority': priority,
            'created_by': createdBy,
          })
          .select()
          .single();

      return TicketModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear ticket: $e');
    }
  }

  // Obtener todos los tickets (con nombre de empresa)
  Future<List<TicketModel>> getAllTickets() async {
    try {
      final response = await _supabase
          .from('support_tickets')
          .select('''
            *,
            companies:company_id (
              name
            )
          ''')
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final ticketJson = Map<String, dynamic>.from(json);
        // Agregar nombre de empresa si existe
        if (json['companies'] != null) {
          final company = json['companies'] as Map<String, dynamic>;
          ticketJson['company_name'] = company['name'] as String?;
        }
        return TicketModel.fromJson(ticketJson);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener tickets: $e');
    }
  }

  // Obtener tickets por empresa
  Future<List<TicketModel>> getTicketsByCompany(String companyId) async {
    try {
      final response = await _supabase
          .from('support_tickets')
          .select('''
            *,
            companies:company_id (
              name
            )
          ''')
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final ticketJson = Map<String, dynamic>.from(json);
        if (json['companies'] != null) {
          final company = json['companies'] as Map<String, dynamic>;
          ticketJson['company_name'] = company['name'] as String?;
        }
        return TicketModel.fromJson(ticketJson);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener tickets de empresa: $e');
    }
  }

  // Obtener ticket por ID
  Future<TicketModel> getTicketById(String ticketId) async {
    try {
      final response = await _supabase
          .from('support_tickets')
          .select('''
            *,
            companies:company_id (
              name
            )
          ''')
          .eq('id', ticketId)
          .single();

      final ticketJson = Map<String, dynamic>.from(response);
      if (response['companies'] != null) {
        final company = response['companies'] as Map<String, dynamic>;
        ticketJson['company_name'] = company['name'] as String?;
      }
      return TicketModel.fromJson(ticketJson);
    } catch (e) {
      throw Exception('Error al obtener ticket: $e');
    }
  }

  // Actualizar estado del ticket
  Future<TicketModel> updateTicketStatus({
    required String ticketId,
    required String status,
    required String updatedBy,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == 'closed') {
        updateData['closed_at'] = DateTime.now().toIso8601String();
        updateData['closed_by'] = updatedBy;
      }

      final response = await _supabase
          .from('support_tickets')
          .update(updateData)
          .eq('id', ticketId)
          .select('''
            *,
            companies:company_id (
              name
            )
          ''')
          .single();

      final ticketJson = Map<String, dynamic>.from(response);
      if (response['companies'] != null) {
        final company = response['companies'] as Map<String, dynamic>;
        ticketJson['company_name'] = company['name'] as String?;
      }
      return TicketModel.fromJson(ticketJson);
    } catch (e) {
      throw Exception('Error al actualizar estado del ticket: $e');
    }
  }

  // Actualizar ticket
  Future<TicketModel> updateTicket({
    required String ticketId,
    String? subject,
    String? description,
    String? priority,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (subject != null) updateData['subject'] = subject;
      if (description != null) updateData['description'] = description;
      if (priority != null) updateData['priority'] = priority;
      if (status != null) {
        updateData['status'] = status;
        if (status == 'closed') {
          updateData['closed_at'] = DateTime.now().toIso8601String();
        }
      }

      final response = await _supabase
          .from('support_tickets')
          .update(updateData)
          .eq('id', ticketId)
          .select('''
            *,
            companies:company_id (
              name
            )
          ''')
          .single();

      final ticketJson = Map<String, dynamic>.from(response);
      if (response['companies'] != null) {
        final company = response['companies'] as Map<String, dynamic>;
        ticketJson['company_name'] = company['name'] as String?;
      }
      return TicketModel.fromJson(ticketJson);
    } catch (e) {
      throw Exception('Error al actualizar ticket: $e');
    }
  }

  // Obtener estadísticas de tickets
  Future<Map<String, dynamic>> getTicketStats() async {
    try {
      final allTickets = await _supabase
          .from('support_tickets')
          .select('status, priority');

      int openTickets = 0;
      int inProgressTickets = 0;
      int closedTickets = 0;
      int urgentTickets = 0;

      for (var ticket in allTickets) {
        final status = ticket['status'] as String;
        final priority = ticket['priority'] as String;

        switch (status) {
          case 'open':
            openTickets++;
            break;
          case 'in_progress':
            inProgressTickets++;
            break;
          case 'closed':
            closedTickets++;
            break;
        }

        if (priority == 'urgent') {
          urgentTickets++;
        }
      }

      return {
        'total': allTickets.length,
        'open': openTickets,
        'in_progress': inProgressTickets,
        'closed': closedTickets,
        'urgent': urgentTickets,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas de tickets: $e');
    }
  }
}

