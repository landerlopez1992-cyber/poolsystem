-- ============================================
-- SOLUCIÓN FINAL: Admin puede leer usuarios workers (SIN RECURSIÓN)
-- ============================================
-- Esta solución NO consulta users dentro de la política
-- Solo verifica workers y company_id directamente

-- PASO 1: Eliminar TODAS las políticas problemáticas
DROP POLICY IF EXISTS "Admin can read company worker users" ON users;

-- PASO 2: Eliminar funciones problemáticas
DROP FUNCTION IF EXISTS is_admin() CASCADE;
DROP FUNCTION IF EXISTS get_admin_company_id() CASCADE;
DROP FUNCTION IF EXISTS get_current_admin_company_id() CASCADE;

-- PASO 3: Crear función que obtiene company_id del admin actual
-- Esta función usa SECURITY DEFINER para evitar RLS
CREATE OR REPLACE FUNCTION get_admin_company_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT company_id 
    FROM users 
    WHERE id = auth.uid() AND role = 'admin'
    LIMIT 1;
$$;

-- PASO 4: Crear política SIMPLE que NO consulta users en la condición USING
-- La política verifica:
-- 1. El usuario es worker (users.role = 'worker')
-- 2. Existe un worker asociado a ese usuario
-- 3. Ese worker pertenece a la empresa del admin (obtenida de la función)
CREATE POLICY "Admin can read company worker users" ON users
    FOR SELECT
    USING (
        users.role = 'worker'
        AND EXISTS (
            SELECT 1 FROM workers w
            WHERE w.user_id = users.id
            AND w.company_id = get_admin_company_id()
        )
    );

-- PASO 5: Dar permisos
GRANT EXECUTE ON FUNCTION get_admin_company_id() TO authenticated;
GRANT EXECUTE ON FUNCTION get_admin_company_id() TO anon;

-- PASO 6: Verificar
SELECT 
    policyname,
    cmd,
    'Política activa' as estado
FROM pg_policies 
WHERE tablename = 'users' 
AND policyname = 'Admin can read company worker users';

-- ⚠️ Si aún causa recursión, el problema puede ser que la función
-- get_admin_company_id() también está causando recursión cuando se llama
-- desde la política. En ese caso, necesitamos una solución diferente.

