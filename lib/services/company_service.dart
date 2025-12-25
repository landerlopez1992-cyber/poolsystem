import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/company_model.dart';
import 'supabase_service.dart';
import '../config/app_config.dart';

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
    String? logoUrl,
    String subscriptionType = 'monthly',
    double subscriptionPrice = 250.0,
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
            'logo_url': logoUrl,
            'subscription_type': subscriptionType,
            'subscription_price': subscriptionPrice,
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
    String? logoUrl,
    String subscriptionType = 'monthly',
    double subscriptionPrice = 250.0,
  }) async {
    try {
      // 1. Crear la empresa
      final company = await createCompany(
        name: name,
        description: description,
        address: address,
        phone: phone,
        email: email,
        logoUrl: logoUrl,
        subscriptionType: subscriptionType,
        subscriptionPrice: subscriptionPrice,
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
    String? subscriptionType,
    double? subscriptionPrice,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (address != null) data['address'] = address;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (logoUrl != null) data['logo_url'] = logoUrl;
      if (subscriptionType != null) data['subscription_type'] = subscriptionType;
      if (subscriptionPrice != null) data['subscription_price'] = subscriptionPrice;

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

  // Subir logo de empresa (usando bytes)
  // NOTA: Este método está deprecado, usar StorageHelper en su lugar
  Future<String> uploadCompanyLogo(String companyId, List<int> fileBytes) async {
    try {
      final fileName = 'logo_$companyId${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePathStorage = 'company-logos/$fileName';
      
      // Convertir List<int> a Uint8List
      final uint8List = Uint8List.fromList(fileBytes);
      
      // Subir a Supabase Storage usando el método correcto
      // En mobile, necesitamos convertir a File
      if (!kIsWeb) {
        final tempFile = File.fromRawPath(uint8List);
        await _supabase.storage
            .from('company-logos')
            .upload(filePathStorage, tempFile);
      } else {
        // En web, usar HTTP directo (similar a StorageHelper)
        final url = '${AppConfig.supabaseUrl}/storage/v1/object/company-logos/$filePathStorage';
        final session = _supabase.auth.currentSession;
        final token = session?.accessToken ?? '';
        
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'image/jpeg',
            'apikey': AppConfig.supabaseAnonKey,
          },
          body: uint8List,
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Error al subir: ${response.statusCode} - ${response.body}');
        }
      }

      // Obtener URL pública
      final publicUrl = _supabase.storage
          .from('company-logos')
          .getPublicUrl(filePathStorage);

      return publicUrl;
    } catch (e) {
      throw Exception('Error al subir logo: $e');
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

  // Obtener estadísticas globales del Super Admin
  Future<Map<String, dynamic>> getSuperAdminStats() async {
    try {
      // 1. Empresas activas e inactivas
      final allCompanies = await _supabase
          .from('companies')
          .select('is_active');
      
      int activeCompanies = 0;
      int inactiveCompanies = 0;
      
      for (var company in allCompanies) {
        if (company['is_active'] == true) {
          activeCompanies++;
        } else {
          inactiveCompanies++;
        }
      }

      // 2. Total de empleados (usuarios con rol admin)
      final adminUsers = await _supabase
          .from('users')
          .select('id')
          .eq('role', 'admin');
      final totalAdmins = (adminUsers as List).length;

      // 3. Total de limpiadores (workers)
      final allWorkers = await _supabase
          .from('workers')
          .select('id');
      final totalWorkers = (allWorkers as List).length;

      // 4. Total de suscripciones activas (suma de precios reales de empresas activas)
      // Obtener todas las empresas activas con sus precios de suscripción
      final activeCompaniesData = await _supabase
          .from('companies')
          .select('subscription_price, subscription_type')
          .eq('is_active', true);
      
      double totalSubscriptions = 0.0;
      int monthlySubscriptions = 0;
      int lifetimeSubscriptions = 0;
      
      for (var company in activeCompaniesData) {
        final price = (company['subscription_price'] as num?)?.toDouble() ?? 0.0;
        final type = company['subscription_type'] as String? ?? 'monthly';
        
        if (type == 'monthly') {
          // Para suscripciones mensuales, sumar el precio mensual
          totalSubscriptions += price;
          monthlySubscriptions++;
        } else if (type == 'lifetime') {
          // Para suscripciones lifetime, sumar el precio total
          totalSubscriptions += price;
          lifetimeSubscriptions++;
        }
      }

      return {
        'active_companies': activeCompanies,
        'inactive_companies': inactiveCompanies,
        'total_companies': activeCompanies + inactiveCompanies,
        'total_admins': totalAdmins,
        'total_workers': totalWorkers,
        'total_subscriptions': totalSubscriptions,
        'monthly_subscriptions': monthlySubscriptions,
        'lifetime_subscriptions': lifetimeSubscriptions,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas globales: $e');
    }
  }
}

