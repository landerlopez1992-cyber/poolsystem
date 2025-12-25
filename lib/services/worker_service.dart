import '../models/worker_model.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class WorkerService {
  final _supabase = SupabaseService.client;
  final _authService = AuthService();

  // Obtener todos los trabajadores de una empresa
  Future<List<WorkerModel>> getWorkersByCompany(String companyId) async {
    try {
      final response = await _supabase
          .from('workers')
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => WorkerModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener trabajadores: $e');
    }
  }

  // Obtener trabajador por ID
  Future<WorkerModel?> getWorkerById(String workerId) async {
    try {
      final response = await _supabase
          .from('workers')
          .select()
          .eq('id', workerId)
          .single();

      return WorkerModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener trabajador: $e');
    }
  }

  // Obtener trabajador por user_id
  Future<WorkerModel?> getWorkerByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('workers')
          .select()
          .eq('user_id', userId)
          .single();

      return WorkerModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Crear trabajador (requiere crear usuario primero)
  Future<WorkerModel> createWorker({
    required String companyId,
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? specialization,
    String? licenseNumber,
    String? avatarUrl,
  }) async {
    try {
      // 1. Crear usuario en auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Error al crear usuario');
      }

      final userId = authResponse.user!.id;

      // 2. Crear registro en tabla users
      await _supabase.from('users').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'role': 'worker',
        'company_id': companyId,
        'phone': phone,
        'avatar_url': avatarUrl,
        'is_active': true,
      });

      // 3. Crear registro en tabla workers
      final response = await _supabase
          .from('workers')
          .insert({
            'company_id': companyId,
            'user_id': userId,
            'full_name': fullName,
            'phone': phone,
            'email': email,
            'specialization': specialization,
            'license_number': licenseNumber,
            'status': 'active',
          })
          .select()
          .single();

      return WorkerModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear trabajador: $e');
    }
  }

  // Actualizar trabajador
  Future<WorkerModel> updateWorker({
    required String workerId,
    String? fullName,
    String? phone,
    String? email,
    String? specialization,
    String? licenseNumber,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (fullName != null) data['full_name'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (specialization != null) data['specialization'] = specialization;
      if (licenseNumber != null) data['license_number'] = licenseNumber;
      if (status != null) data['status'] = status;

      final response = await _supabase
          .from('workers')
          .update(data)
          .eq('id', workerId)
          .select()
          .single();

      return WorkerModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar trabajador: $e');
    }
  }

  // Actualizar ubicación del trabajador
  Future<void> updateWorkerLocation({
    required String workerId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _supabase
          .from('workers')
          .update({
            'current_latitude': latitude,
            'current_longitude': longitude,
            'last_location_update': DateTime.now().toIso8601String(),
          })
          .eq('id', workerId);
    } catch (e) {
      throw Exception('Error al actualizar ubicación: $e');
    }
  }

  // Actualizar foto de perfil del trabajador
  Future<void> updateWorkerProfilePhoto({
    required String workerId,
    required String photoUrl,
  }) async {
    try {
      // Actualizar en tabla users
      final worker = await getWorkerById(workerId);
      if (worker != null) {
        await _supabase
            .from('users')
            .update({'avatar_url': photoUrl})
            .eq('id', worker.userId);
      }
    } catch (e) {
      throw Exception('Error al actualizar foto de perfil: $e');
    }
  }

  // Eliminar trabajador (soft delete)
  Future<void> deleteWorker(String workerId) async {
    try {
      await _supabase
          .from('workers')
          .update({'status': 'inactive'})
          .eq('id', workerId);
    } catch (e) {
      throw Exception('Error al eliminar trabajador: $e');
    }
  }
}

