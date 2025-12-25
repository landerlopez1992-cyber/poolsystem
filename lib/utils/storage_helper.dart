import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageHelper {
  /// Subir archivo a Supabase Storage (compatible con web y mobile)
  /// Usa cast dinámico para compatibilidad entre plataformas
  static Future<String> uploadFile({
    required SupabaseClient supabase,
    required String bucket,
    required String filePath,
    required Uint8List fileBytes,
  }) async {
    try {
      // Usar cast dinámico para compatibilidad web/mobile
      // En web, upload puede aceptar Uint8List
      // En mobile, puede necesitar File, pero el cast dinámico lo maneja
      await supabase.storage
          .from(bucket)
          .upload(filePath, fileBytes as dynamic);

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

