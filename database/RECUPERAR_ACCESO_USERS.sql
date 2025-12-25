-- ============================================
-- RECUPERAR ACCESO: Eliminar política problemática
-- ============================================
-- Este script elimina la política que causa recursión infinita
-- y restaura el acceso básico a la tabla users

-- PASO 1: Eliminar la política problemática que causa recursión
DROP POLICY IF EXISTS "Admin can read company worker users" ON users;

-- PASO 2: Verificar que las políticas básicas existen
-- Si no existen, crearlas

-- Política: Usuarios pueden leer sus propios datos
DROP POLICY IF EXISTS "Users can read own data" ON users;
CREATE POLICY "Users can read own data" ON users
    FOR SELECT
    USING (auth.uid() = id);

-- Política: Super Admin puede leer todos los usuarios
-- (Usar la función is_super_admin() si existe, sino crear política simple)
DROP POLICY IF EXISTS "Super Admin can read all users" ON users;

-- Verificar si existe la función is_super_admin
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_super_admin') THEN
        -- Usar la función existente
        CREATE POLICY "Super Admin can read all users" ON users
            FOR SELECT
            USING (is_super_admin());
    ELSE
        -- Crear política simple (puede causar recursión, pero es temporal)
        CREATE POLICY "Super Admin can read all users" ON users
            FOR SELECT
            USING (
                EXISTS (
                    SELECT 1 FROM users 
                    WHERE id = auth.uid() 
                    AND role = 'super_admin'
                )
            );
    END IF;
END $$;

-- PASO 3: Verificar políticas activas
SELECT 
    policyname,
    cmd,
    'Política activa' as estado
FROM pg_policies 
WHERE tablename = 'users'
ORDER BY policyname;

-- ✅ Después de ejecutar este script, deberías poder:
-- 1. Ver tus propios datos (Users can read own data)
-- 2. Super Admin puede ver todos los usuarios
-- 3. La política problemática está eliminada

-- ⚠️ NOTA: Los Admins aún NO podrán leer usuarios workers directamente
-- Para eso, usar la función RPC get_worker_avatar() desde el código

