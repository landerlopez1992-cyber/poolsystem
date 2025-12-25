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

  // Actualizar usuario (o crearlo si no existe)
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
      var existingUser = await _supabase
          .from('users')
          .select('id, email, role, company_id')
          .eq('id', userId)
          .maybeSingle();

      print('🔍 Usuario existente en public.users: ${existingUser != null ? "SÍ" : "NO"}');
      
      // Si el usuario no existe en public.users, verificar si existe en workers y crearlo
      if (existingUser == null) {
        print('⚠️ Usuario no encontrado en public.users, buscando en workers...');
        
        try {
          // Buscar en workers para obtener información del usuario
          final workerData = await _supabase
              .from('workers')
              .select('company_id, email, full_name')
              .eq('user_id', userId)
              .maybeSingle();
          
          if (workerData != null) {
            print('✅ Worker encontrado, creando usuario en public.users...');
            print('   - Email del worker: ${workerData['email']}');
            print('   - Company ID: ${workerData['company_id']}');
            
            try {
              // Intentar crear el usuario usando la función de base de datos (si existe)
              // o directamente con INSERT
              try {
                // Primero intentar con la función create_user_for_worker (más seguro)
                final functionResult = await _supabase.rpc(
                  'create_user_for_worker',
                  params: {
                    'p_user_id': userId,
                    'p_email': workerData['email'] ?? '',
                    'p_full_name': workerData['full_name'] ?? fullName ?? '',
                    'p_company_id': workerData['company_id'],
                    'p_phone': phone,
                    'p_avatar_url': avatarUrl,
                  },
                );
                
                if (functionResult != null) {
                  print('✅ Usuario creado usando función create_user_for_worker');
                  existingUser = UserModel.fromJson(functionResult as Map<String, dynamic>);
                }
              } catch (functionError) {
                print('⚠️ Función no disponible, intentando INSERT directo: $functionError');
                
                // Si la función no existe, intentar INSERT directo
                final newUser = await _supabase
                    .from('users')
                    .insert({
                      'id': userId,
                      'email': workerData['email'] ?? '',
                      'full_name': workerData['full_name'] ?? fullName ?? '',
                      'role': 'worker',
                      'company_id': workerData['company_id'],
                      'phone': phone,
                      'avatar_url': avatarUrl,
                      'is_active': isActive ?? true,
                    })
                    .select()
                    .single();
                
                print('✅ Usuario creado exitosamente en public.users');
                existingUser = newUser;
              }
            } catch (insertError) {
              print('❌ Error al INSERTAR usuario: $insertError');
              // Si falla por RLS, mostrar mensaje claro
              throw Exception('No se pudo crear el usuario en la base de datos. Error RLS: $insertError. Por favor, ejecuta el script SQL: database/SOLUCION_DEFINITIVA_RLS_INSERT.sql');
            }
          } else {
            throw Exception('Usuario no encontrado en la base de datos ni en workers. userId: $userId');
          }
        } catch (e) {
          print('❌ Error al crear usuario: $e');
          throw Exception('Usuario no encontrado en la base de datos. userId: $userId. Error: $e');
        }
      } else {
        print('   - Email: ${existingUser['email']}');
        print('   - Role: ${existingUser['role']}');
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

