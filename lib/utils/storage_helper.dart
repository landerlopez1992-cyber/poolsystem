import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

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
        // En web, usar uploadBinary que acepta Uint8List directamente
        await supabase.storage
            .from(bucket)
            .uploadBinary(filePath, fileBytes);
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

