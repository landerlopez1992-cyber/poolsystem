-- ============================================
-- CREAR BUCKET DE AVATARES EN SUPABASE STORAGE
-- ============================================
-- Ejecuta este script en el SQL Editor de Supabase

-- Crear bucket 'avatars' si no existe
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars', 
  'avatars', 
  true,  -- Público para que las imágenes sean accesibles
  5242880,  -- 5 MB límite
  ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp']  -- Tipos MIME permitidos
)
ON CONFLICT (id) DO NOTHING;

-- Verificar que el bucket fue creado
SELECT id, name, public, created_at 
FROM storage.buckets 
WHERE id = 'avatars';

-- ============================================
-- IMPORTANTE: Después de crear el bucket,
-- ejecuta las políticas RLS desde:
-- database/politicas_storage_rls.sql
-- ============================================

