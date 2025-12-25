-- ============================================
-- SOLUCIÓN DEFINITIVA: Admin puede leer usuarios workers (SIN RECURSIÓN)
-- ============================================
-- Este script elimina TODAS las políticas problemáticas y crea una solución
-- que NO causa recursión infinita

-- PASO 1: Eliminar TODAS las políticas problemáticas relacionadas con Admin
DROP POLICY IF EXISTS "Admin can read company worker users" ON users;
DROP POLICY IF EXISTS "Company Admin can insert worker users" ON users;

-- PASO 2: Eliminar funciones problemáticas si existen
DROP FUNCTION IF EXISTS is_admin() CASCADE;
DROP FUNCTION IF EXISTS get_admin_company_id() CASCADE;
DROP FUNCTION IF EXISTS get_current_admin_company_id() CASCADE;

-- PASO 3: Crear función SECURITY DEFINER que obtiene el company_id del admin
-- Esta función NO pasa por RLS, evitando recursión
CREATE OR REPLACE FUNCTION get_current_admin_company_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
    v_company_id UUID;
BEGIN
    -- Esta consulta se ejecuta con permisos de definer, NO pasa por RLS
    -- Por lo tanto, NO causa recursión
    SELECT company_id INTO v_company_id
    FROM users
    WHERE id = auth.uid() 
    AND role = 'admin'
    LIMIT 1;
    
    RETURN v_company_id;
END;
$$;

-- PASO 4: Crear política que usa la función (NO consulta users directamente)
-- La política solo verifica:
-- 1. El usuario a leer es worker (users.role = 'worker')
-- 2. Existe un worker asociado a ese usuario
-- 3. Ese worker pertenece a la empresa del admin (obtenida de la función)
CREATE POLICY "Admin can read company worker users" ON users
    FOR SELECT
    USING (
        -- Solo aplica a usuarios con role 'worker'
        users.role = 'worker'
        AND
        -- Verificar que existe un worker asociado a este usuario
        -- Y que ese worker pertenece a la empresa del admin actual
        EXISTS (
            SELECT 1 FROM workers w
            WHERE w.user_id = users.id
            AND w.company_id = get_current_admin_company_id()
        )
    );

-- PASO 5: Dar permisos de ejecución a la función
GRANT EXECUTE ON FUNCTION get_current_admin_company_id() TO authenticated;
GRANT EXECUTE ON FUNCTION get_current_admin_company_id() TO anon;

-- PASO 6: Verificar que la política se creó
SELECT 
    'Política creada' as tipo,
    policyname as nombre,
    cmd as operacion
FROM pg_policies 
WHERE tablename = 'users' 
AND policyname = 'Admin can read company worker users';

-- PASO 7: Verificar que la función se creó
SELECT 
    'Función creada' as tipo,
    proname as nombre
FROM pg_proc 
WHERE proname = 'get_current_admin_company_id';

-- ✅ LISTO! 
-- La función get_current_admin_company_id() usa SECURITY DEFINER
-- y puede leer users sin pasar por RLS, evitando recursión infinita.
-- La política NO consulta users directamente, solo verifica workers.

