import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class StorageHelper {
  /// Subir archivo a Supabase Storage (compatible con web y mobile)
  static Future<String> uploadFile({
    required SupabaseClient supabase,
    required String bucket,
    required String filePath,
    required Uint8List fileBytes,
  }) async {
    try {
      print('📤 StorageHelper.uploadFile - bucket: $bucket, filePath: $filePath, tamaño: ${fileBytes.length} bytes');
      
      if (kIsWeb) {
        // En web, usar el método HTTP directo de Supabase
        final url = '${AppConfig.supabaseUrl}/storage/v1/object/$bucket/$filePath';
        print('🌐 URL de subida (web): $url');
        
        // Obtener el token de autenticación
        final session = supabase.auth.currentSession;
        final token = session?.accessToken ?? '';
        
        if (token.isEmpty) {
          throw Exception('No hay sesión activa. Token vacío.');
        }
        
        print('🔑 Token obtenido: ${token.substring(0, 20)}...');
        
        // Subir usando HTTP POST (Supabase Storage usa POST para upload)
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'image/jpeg',
            'apikey': AppConfig.supabaseAnonKey,
            'x-upsert': 'true', // Permite sobrescribir si existe
          },
          body: fileBytes,
        );

        print('📡 Respuesta HTTP: ${response.statusCode}');
        print('📄 Body: ${response.body}');

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Error al subir: ${response.statusCode} - ${response.body}');
        }
        
        print('✅ Archivo subido exitosamente (web)');
      } else {
        // En mobile, convertir bytes a File temporal
        print('📱 Subiendo archivo (mobile)...');
        final tempFile = File.fromRawPath(fileBytes);
        await supabase.storage
            .from(bucket)
            .upload(filePath, tempFile);
        print('✅ Archivo subido exitosamente (mobile)');
      }

      // Obtener URL pública
      final publicUrl = supabase.storage
          .from(bucket)
          .getPublicUrl(filePath);

      print('🔗 URL pública generada: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ ERROR en StorageHelper.uploadFile: $e');
      throw Exception('Error al subir archivo: $e');
    }
  }
}

