import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:http/http.dart' as http;

class StorageHelper {
  /// Subir archivo a Supabase Storage (compatible con web y mobile)
  static Future<String> uploadFile({
    required SupabaseClient supabase,
    required String bucket,
    required String filePath,
    required Uint8List fileBytes,
  }) async {
    try {
      if (kIsWeb) {
        // En web, usar el método HTTP directo de Supabase
        // Construir la URL del endpoint de storage
        final url = '${supabase.supabaseUrl}/storage/v1/object/$bucket/$filePath';
        
        // Obtener el token de autenticación
        final session = supabase.auth.currentSession;
        final token = session?.accessToken ?? '';
        
        // Subir usando HTTP PUT
        final response = await http.put(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'image/jpeg',
            'apikey': supabase.supabaseKey,
          },
          body: fileBytes,
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Error al subir: ${response.statusCode} - ${response.body}');
        }
      } else {
        // En mobile, convertir bytes a File temporal
        final tempFile = File.fromRawPath(fileBytes);
        await supabase.storage
            .from(bucket)
            .upload(filePath, tempFile);
      }

      // Obtener URL pública
      final publicUrl = supabase.storage
          .from(bucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Error al subir archivo: $e');
    }
  }
}

