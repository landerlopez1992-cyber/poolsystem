import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  final _supabase = SupabaseService.client;

  // Iniciar sesión
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return await getUserById(response.user!.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // Obtener usuario actual
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      return await getUserById(user.id);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  // Obtener usuario por ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle(); // Cambiar a maybeSingle para manejar cuando no existe

      if (response == null) {
        return null; // Usuario no existe en tabla users
      }

      return UserModel.fromJson(response);
    } catch (e) {
      // Si hay error, retornar null en lugar de lanzar excepción
      print('Error al obtener usuario: $e');
      return null;
    }
  }

  // Verificar si el usuario es super admin
  Future<bool> isSuperAdmin() async {
    final user = await getCurrentUser();
    return user?.isSuperAdmin ?? false;
  }

  // Verificar si el usuario es admin
  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.isAdmin ?? false;
  }

  // Verificar si el usuario es trabajador
  Future<bool> isWorker() async {
    final user = await getCurrentUser();
    return user?.isWorker ?? false;
  }
}

