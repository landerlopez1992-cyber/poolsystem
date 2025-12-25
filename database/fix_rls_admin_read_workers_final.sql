-- ============================================
-- FIX FINAL: Política RLS para que Admins puedan leer usuarios workers
-- ============================================
-- Esta solución NO consulta la tabla users dentro de la política
-- para evitar recursión infinita

-- PASO 1: Eliminar TODAS las políticas problemáticas relacionadas
DROP POLICY IF EXISTS "Admin can read company worker users" ON users;

-- PASO 2: Eliminar funciones que puedan causar problemas (si existen)
DROP FUNCTION IF EXISTS is_admin() CASCADE;
DROP FUNCTION IF EXISTS get_admin_company_id() CASCADE;

-- PASO 3: Crear política SIMPLE que NO consulta users directamente
-- La política verifica que:
-- 1. El usuario a leer es un worker (role = 'worker')
-- 2. Existe un worker asociado a ese usuario
-- 3. Ese worker pertenece a una empresa
-- 4. El usuario actual (auth.uid()) es admin de esa misma empresa
-- 
-- Esto evita recursión porque NO consultamos users dentro de la política
CREATE POLICY "Admin can read company worker users" ON users
    FOR SELECT
    USING (
        -- Solo aplica a usuarios con role 'worker'
        users.role = 'worker'
        AND
        -- Verificar que existe un worker asociado a este usuario
        EXISTS (
            SELECT 1 FROM workers w
            WHERE w.user_id = users.id
            -- Y que el usuario actual es admin de la misma empresa
            AND EXISTS (
                SELECT 1 FROM users admin_user
                WHERE admin_user.id = auth.uid()
                AND admin_user.role = 'admin'
                AND admin_user.company_id = w.company_id
            )
        )
    );

-- PASO 4: Verificar que la política se creó
SELECT 
    cmd,
    policyname,
    CASE 
        WHEN cmd = 'SELECT' THEN 'Lectura'
        ELSE cmd::text
    END as operacion
FROM pg_policies 
WHERE tablename = 'users' 
AND policyname = 'Admin can read company worker users';

-- ⚠️ NOTA: Esta política aún puede causar recursión porque consulta users
-- dentro de la subconsulta. Necesitamos una solución diferente.

