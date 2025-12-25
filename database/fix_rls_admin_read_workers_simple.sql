-- ============================================
-- FIX SIMPLE: Política RLS para que Admins puedan leer usuarios workers
-- ============================================
-- Esta solución usa una función SECURITY DEFINER que NO consulta users
-- en la política misma, evitando recursión

-- PASO 1: Eliminar TODAS las políticas problemáticas
DROP POLICY IF EXISTS "Admin can read company worker users" ON users;

-- PASO 2: Eliminar funciones problemáticas si existen
DROP FUNCTION IF EXISTS is_admin() CASCADE;
DROP FUNCTION IF EXISTS get_admin_company_id() CASCADE;

-- PASO 3: Crear función que obtiene el company_id del admin actual
-- Esta función NO consulta users en la política, solo en la función
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
    -- Esta consulta se ejecuta con permisos de definer, no pasa por RLS
    SELECT company_id INTO v_company_id
    FROM users
    WHERE id = auth.uid() AND role = 'admin'
    LIMIT 1;
    
    RETURN v_company_id;
END;
$$;

-- PASO 4: Crear política que usa la función (sin consultar users directamente)
CREATE POLICY "Admin can read company worker users" ON users
    FOR SELECT
    USING (
        -- El usuario a leer es un worker
        users.role = 'worker'
        AND
        -- Y existe un worker asociado a este usuario de la empresa del admin
        EXISTS (
            SELECT 1 FROM workers w
            WHERE w.user_id = users.id
            AND w.company_id = get_current_admin_company_id()
        )
    );

-- PASO 5: Dar permisos de ejecución
GRANT EXECUTE ON FUNCTION get_current_admin_company_id() TO authenticated;
GRANT EXECUTE ON FUNCTION get_current_admin_company_id() TO anon;

-- PASO 6: Verificar que la política se creó
SELECT 
    cmd,
    policyname,
    'Política creada' as estado
FROM pg_policies 
WHERE tablename = 'users' 
AND policyname = 'Admin can read company worker users';

-- ✅ LISTO! La función get_current_admin_company_id() usa SECURITY DEFINER
-- y puede leer users sin pasar por RLS, evitando recursión infinita

