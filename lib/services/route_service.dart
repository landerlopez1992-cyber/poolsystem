import '../models/route_model.dart';
import 'supabase_service.dart';

class RouteService {
  final _supabase = SupabaseService.client;

  // Obtener todas las rutas de una empresa
  Future<List<RouteModel>> getRoutesByCompany(String companyId) async {
    try {
      final response = await _supabase
          .from('routes')
          .select()
          .eq('company_id', companyId)
          .order('scheduled_date', ascending: false);

      return (response as List)
          .map((json) => RouteModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener rutas: $e');
    }
  }

  // Obtener rutas de un trabajador
  Future<List<RouteModel>> getRoutesByWorker(String workerId) async {
    try {
      final response = await _supabase
          .from('routes')
          .select()
          .eq('worker_id', workerId)
          .order('scheduled_date', ascending: false);

      return (response as List)
          .map((json) => RouteModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener rutas: $e');
    }
  }

  // Obtener ruta por ID
  Future<RouteModel?> getRouteById(String routeId) async {
    try {
      final response = await _supabase
          .from('routes')
          .select()
          .eq('id', routeId)
          .single();

      return RouteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener ruta: $e');
    }
  }

  // Crear nueva ruta
  Future<RouteModel> createRoute({
    required String companyId,
    required String workerId,
    required String name,
    required DateTime scheduledDate,
    String? description,
    required List<String> clientIds,
  }) async {
    try {
      final response = await _supabase
          .from('routes')
          .insert({
            'company_id': companyId,
            'worker_id': workerId,
            'name': name,
            'description': description,
            'scheduled_date': scheduledDate.toIso8601String(),
            'status': 'scheduled',
            'client_ids': clientIds,
            'total_clients': clientIds.length,
            'completed_clients': 0,
          })
          .select()
          .single();

      return RouteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear ruta: $e');
    }
  }

  // Actualizar ruta
  Future<RouteModel> updateRoute({
    required String routeId,
    String? name,
    String? description,
    DateTime? scheduledDate,
    String? status,
    List<String>? clientIds,
    int? completedClients,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (scheduledDate != null) data['scheduled_date'] = scheduledDate.toIso8601String();
      if (status != null) data['status'] = status;
      if (clientIds != null) {
        data['client_ids'] = clientIds;
        data['total_clients'] = clientIds.length;
      }
      if (completedClients != null) data['completed_clients'] = completedClients;

      final response = await _supabase
          .from('routes')
          .update(data)
          .eq('id', routeId)
          .select()
          .single();

      return RouteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar ruta: $e');
    }
  }

  // Iniciar ruta
  Future<RouteModel> startRoute(String routeId) async {
    try {
      final response = await _supabase
          .from('routes')
          .update({
            'status': 'in_progress',
            'start_date': DateTime.now().toIso8601String(),
          })
          .eq('id', routeId)
          .select()
          .single();

      return RouteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al iniciar ruta: $e');
    }
  }

  // Completar ruta
  Future<RouteModel> completeRoute(String routeId) async {
    try {
      final response = await _supabase
          .from('routes')
          .update({
            'status': 'completed',
            'end_date': DateTime.now().toIso8601String(),
          })
          .eq('id', routeId)
          .select()
          .single();

      return RouteModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al completar ruta: $e');
    }
  }

  // Agregar información a la ruta (notas, actualizaciones)
  Future<void> addRouteInfo({
    required String routeId,
    String? notes,
    int? completedClients,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (completedClients != null) {
        data['completed_clients'] = completedClients;
      }
      // Aquí podrías agregar un campo 'notes' o 'updates' a la tabla routes
      // Por ahora actualizamos el completed_clients

      await _supabase
          .from('routes')
          .update(data)
          .eq('id', routeId);
    } catch (e) {
      throw Exception('Error al agregar información: $e');
    }
  }
}

