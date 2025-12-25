import '../models/user_model.dart';
import 'supabase_service.dart';

class UserService {
  final _supabase = SupabaseService.client;

  // Crear usuario administrador para una empresa
  Future<UserModel> createAdminUser({
    required String companyId,
    required String email,
    required String password,
    required String fullName,
    String? phone,
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
      final response = await _supabase
          .from('users')
          .insert({
            'id': userId,
            'email': email,
            'full_name': fullName,
            'role': 'admin',
            'company_id': companyId,
            'phone': phone,
            'avatar_url': avatarUrl,
            'is_active': true,
          })
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear usuario administrador: $e');
    }
  }

  // Obtener todos los usuarios de una empresa
  Future<List<UserModel>> getUsersByCompany(String companyId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

  // Obtener solo los administradores (empleados) de una empresa
  Future<List<UserModel>> getAdminUsersByCompany(String companyId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('company_id', companyId)
          .eq('role', 'admin')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener administradores: $e');
    }
  }

  // Obtener usuario por ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Actualizar usuario
  Future<UserModel> updateUser({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
    bool? isActive,
  }) async {
    try {
      print('🔄 UserService.updateUser - userId: $userId');
      final Map<String, dynamic> data = {};
      if (fullName != null) data['full_name'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (avatarUrl != null) {
        data['avatar_url'] = avatarUrl;
        print('📸 Avatar URL a guardar: $avatarUrl');
      }
      if (isActive != null) data['is_active'] = isActive;

      print('📝 Datos a actualizar: $data');

      // Verificar que el usuario existe antes de actualizar
      final existingUser = await _supabase
          .from('users')
          .select('id, email, role')
          .eq('id', userId)
          .maybeSingle();

      print('🔍 Usuario existente: ${existingUser != null ? "SÍ" : "NO"}');
      if (existingUser != null) {
        print('   - Email: ${existingUser['email']}');
        print('   - Role: ${existingUser['role']}');
      }

      if (existingUser == null) {
        throw Exception('Usuario no encontrado en la base de datos. userId: $userId');
      }

      print('💾 Ejecutando UPDATE en tabla users...');
      final response = await _supabase
          .from('users')
          .update(data)
          .eq('id', userId)
          .select()
          .single();

      print('✅ Usuario actualizado exitosamente');
      print('   - Avatar URL guardada: ${response['avatar_url']}');
      
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ ERROR en UserService.updateUser: $e');
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  // Suspender/Activar usuario
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _supabase
          .from('users')
          .update({'is_active': isActive})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Error al cambiar estado de usuario: $e');
    }
  }
}

