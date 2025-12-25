import '../models/client_model.dart';
import 'supabase_service.dart';

class ClientService {
  final _supabase = SupabaseService.client;

  // Obtener todos los clientes de una empresa
  Future<List<ClientModel>> getClientsByCompany(String companyId) async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ClientModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener clientes: $e');
    }
  }

  // Obtener cliente por ID
  Future<ClientModel?> getClientById(String clientId) async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .eq('id', clientId)
          .single();

      return ClientModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener cliente: $e');
    }
  }

  // Crear nuevo cliente
  Future<ClientModel> createClient({
    required String companyId,
    required String fullName,
    String? email,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? poolType,
    String? poolSize,
    String? notes,
    double? monthlyFee,
  }) async {
    try {
      final response = await _supabase
          .from('clients')
          .insert({
            'company_id': companyId,
            'full_name': fullName,
            'email': email,
            'phone': phone,
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
            'pool_type': poolType,
            'pool_size': poolSize,
            'notes': notes,
            'monthly_fee': monthlyFee,
            'status': 'active',
          })
          .select()
          .single();

      return ClientModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear cliente: $e');
    }
  }

  // Actualizar cliente
  Future<ClientModel> updateClient({
    required String clientId,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? poolType,
    String? poolSize,
    String? notes,
    double? monthlyFee,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (fullName != null) data['full_name'] = fullName;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (poolType != null) data['pool_type'] = poolType;
      if (poolSize != null) data['pool_size'] = poolSize;
      if (notes != null) data['notes'] = notes;
      if (monthlyFee != null) data['monthly_fee'] = monthlyFee;
      if (status != null) data['status'] = status;

      final response = await _supabase
          .from('clients')
          .update(data)
          .eq('id', clientId)
          .select()
          .single();

      return ClientModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar cliente: $e');
    }
  }

  // Eliminar cliente (soft delete)
  Future<void> deleteClient(String clientId) async {
    try {
      await _supabase
          .from('clients')
          .update({'status': 'inactive'})
          .eq('id', clientId);
    } catch (e) {
      throw Exception('Error al eliminar cliente: $e');
    }
  }
}

