-- ============================================
-- POLÍTICAS RLS PARA SUPABASE STORAGE
-- ============================================
-- Ejecuta estos comandos en el SQL Editor de Supabase
-- para permitir subida y lectura de archivos en los buckets

-- ============================================
-- BUCKET: company-logos
-- ============================================

-- 1. Política de LECTURA PÚBLICA (SELECT)
-- Permite que cualquiera pueda ver los logos
CREATE POLICY "Public Access for company logos"
ON storage.objects FOR SELECT
USING (bucket_id = 'company-logos');

-- 2. Política de SUBIDA (INSERT) - Solo usuarios autenticados
-- Permite que usuarios autenticados suban logos
CREATE POLICY "Authenticated users can upload company logos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'company-logos' 
  AND auth.role() = 'authenticated'
);

-- 3. Política de ACTUALIZACIÓN (UPDATE) - Solo usuarios autenticados
-- Permite que usuarios autenticados actualicen logos
CREATE POLICY "Authenticated users can update company logos"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'company-logos' 
  AND auth.role() = 'authenticated'
)
WITH CHECK (
  bucket_id = 'company-logos' 
  AND auth.role() = 'authenticated'
);

-- 4. Política de ELIMINACIÓN (DELETE) - Solo usuarios autenticados
-- Permite que usuarios autenticados eliminen logos
CREATE POLICY "Authenticated users can delete company logos"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'company-logos' 
  AND auth.role() = 'authenticated'
);

-- ============================================
-- BUCKET: avatars
-- ============================================

-- 1. Política de LECTURA PÚBLICA (SELECT)
CREATE POLICY "Public Access for avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

-- 2. Política de SUBIDA (INSERT) - Solo usuarios autenticados
CREATE POLICY "Authenticated users can upload avatars"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.role() = 'authenticated'
);

-- 3. Política de ACTUALIZACIÓN (UPDATE) - Solo usuarios autenticados
CREATE POLICY "Authenticated users can update avatars"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars' 
  AND auth.role() = 'authenticated'
)
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.role() = 'authenticated'
);

-- 4. Política de ELIMINACIÓN (DELETE) - Solo usuarios autenticados
CREATE POLICY "Authenticated users can delete avatars"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'avatars' 
  AND auth.role() = 'authenticated'
);

-- ============================================
-- NOTAS IMPORTANTES:
-- ============================================
-- 1. Estas políticas permiten que CUALQUIER usuario autenticado
--    pueda subir/actualizar/eliminar archivos en los buckets.
-- 
-- 2. Si quieres restringir más (ej: solo Super Admin puede subir logos),
--    cambia 'authenticated' por una verificación específica:
--    AND EXISTS (
--      SELECT 1 FROM users 
--      WHERE users.id = auth.uid() 
--      AND users.role = 'super_admin'
--    )
--
-- 3. Para verificar que las políticas están activas:
--    SELECT * FROM pg_policies WHERE tablename = 'objects';
-- ============================================

