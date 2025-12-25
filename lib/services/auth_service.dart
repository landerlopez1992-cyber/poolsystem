import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  final _supabase = SupabaseService.client;

  // Iniciar sesión
  Future<UserModel?> signIn(String email, String password) async {
    try {
      print('🔐 Intentando iniciar sesión con: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Autenticación exitosa. User ID: ${response.user!.id}');
        final user = await getUserById(response.user!.id);
        if (user != null) {
          print('✅ Usuario encontrado en BD. Rol: ${user.role}');
        } else {
          print('❌ Usuario NO encontrado en tabla users. Necesita ejecutar SQL.');
        }
        return user;
      }
      print('❌ No se pudo autenticar');
      return null;
    } catch (e) {
      print('❌ Error en signIn: $e');
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
      print('🔍 Buscando usuario en BD con ID: $userId');
      
      // Intentar primero por ID
      var response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      // Si no se encuentra por ID, intentar por email del usuario auth
      if (response == null) {
        print('⚠️ No encontrado por ID, intentando obtener email de auth...');
        try {
          final authUser = _supabase.auth.currentUser;
          if (authUser != null && authUser.email != null) {
            print('🔍 Buscando por email: ${authUser.email}');
            response = await _supabase
                .from('users')
                .select()
                .eq('email', authUser.email!)
                .maybeSingle();
          }
        } catch (e) {
          print('⚠️ Error al buscar por email: $e');
        }
      }

      if (response == null) {
        print('❌ Usuario NO encontrado en tabla users. ID: $userId');
        print('💡 SOLUCIÓN: Verifica que el ID en auth.users coincida con el ID en users');
        return null;
      }

      print('✅ Usuario encontrado: ${response['email']} - Rol: ${response['role']}');
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ Error al obtener usuario: $e');
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

