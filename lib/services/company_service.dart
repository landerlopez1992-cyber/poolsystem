import '../models/company_model.dart';
import 'supabase_service.dart';

class CompanyService {
  final _supabase = SupabaseService.client;

  // Obtener todas las empresas (Super Admin)
  // Por defecto solo trae empresas activas, pero se puede cambiar
  Future<List<CompanyModel>> getAllCompanies({bool onlyActive = true}) async {
    try {
      var query = _supabase
          .from('companies')
          .select();
      
      // Filtrar solo activas si se solicita
      if (onlyActive) {
        query = query.eq('is_active', true);
      }
      
      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => CompanyModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener empresas: $e');
    }
  }

  // Obtener empresa por ID
  Future<CompanyModel?> getCompanyById(String companyId) async {
    try {
      final response = await _supabase
          .from('companies')
          .select()
          .eq('id', companyId)
          .single();

      return CompanyModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener empresa: $e');
    }
  }

  // Crear nueva empresa (Super Admin)
  Future<CompanyModel> createCompany({
    required String name,
    String? description,
    String? address,
    String? phone,
    String? email,
  }) async {
    try {
      final response = await _supabase
          .from('companies')
          .insert({
            'name': name,
            'description': description,
            'address': address,
            'phone': phone,
            'email': email,
            'is_active': true,
          })
          .select()
          .single();

      return CompanyModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear empresa: $e');
    }
  }

  // Crear empresa con usuario administrador
  Future<CompanyModel> createCompanyWithAdmin({
    required String name,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? adminEmail,
    required String adminPassword,
  }) async {
    try {
      // 1. Crear la empresa
      final company = await createCompany(
        name: name,
        description: description,
        address: address,
        phone: phone,
        email: email,
      );

      // 2. Si hay email de admin, crear el usuario administrador
      if (adminEmail != null && adminEmail.isNotEmpty) {
        // Crear usuario en auth
        final authResponse = await _supabase.auth.signUp(
          email: adminEmail,
          password: adminPassword,
        );

        if (authResponse.user == null) {
          throw Exception('Error al crear usuario administrador');
        }

        final userId = authResponse.user!.id;

        // Crear registro en tabla users
        await _supabase.from('users').insert({
          'id': userId,
          'email': adminEmail,
          'full_name': name, // Usar el nombre de la empresa como nombre del admin
          'role': 'admin',
          'company_id': company.id,
          'phone': phone,
          'is_active': true,
        });
      }

      return company;
    } catch (e) {
      throw Exception('Error al crear empresa con administrador: $e');
    }
  }

  // Actualizar empresa
  Future<CompanyModel> updateCompany({
    required String companyId,
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? logoUrl,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (address != null) data['address'] = address;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (logoUrl != null) data['logo_url'] = logoUrl;

      final response = await _supabase
          .from('companies')
          .update(data)
          .eq('id', companyId)
          .select()
          .single();

      return CompanyModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar empresa: $e');
    }
  }

  // Suspender/Activar empresa
  Future<void> toggleCompanyStatus(String companyId, bool isActive) async {
    try {
      await _supabase
          .from('companies')
          .update({'is_active': isActive})
          .eq('id', companyId);
    } catch (e) {
      throw Exception('Error al cambiar estado de empresa: $e');
    }
  }

  // Eliminar empresa (soft delete)
  Future<void> deleteCompany(String companyId) async {
    try {
      await _supabase
          .from('companies')
          .update({'is_active': false})
          .eq('id', companyId);
    } catch (e) {
      throw Exception('Error al eliminar empresa: $e');
    }
  }

  // Obtener estadísticas de empresa
  Future<Map<String, dynamic>> getCompanyStats(String companyId) async {
    try {
      // Obtener conteos usando count
      final workersResponse = await _supabase
          .from('workers')
          .select('id')
          .eq('company_id', companyId);

      final clientsResponse = await _supabase
          .from('clients')
          .select('id')
          .eq('company_id', companyId);

      final routesResponse = await _supabase
          .from('routes')
          .select('id')
          .eq('company_id', companyId);

      return {
        'total_workers': (workersResponse as List).length,
        'total_clients': (clientsResponse as List).length,
        'total_routes': (routesResponse as List).length,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }
}

