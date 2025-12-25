-- ============================================
-- FIX: Política RLS para que Admins puedan leer usuarios workers (SIN RECURSIÓN)
-- ============================================
-- Este script elimina la política problemática y crea una nueva usando
-- una función helper con SECURITY DEFINER para evitar recursión infinita

-- PASO 1: Eliminar la política problemática que causa recursión
DROP POLICY IF EXISTS "Admin can read company worker users" ON users;

-- PASO 2: Crear función helper para verificar si el usuario actual es admin
-- Esta función usa SECURITY DEFINER para evitar problemas de RLS
DROP FUNCTION IF EXISTS is_admin();

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
    v_user_role TEXT;
BEGIN
    -- Obtener el rol del usuario actual sin pasar por RLS
    SELECT role INTO v_user_role
    FROM users
    WHERE id = auth.uid();
    
    RETURN v_user_role = 'admin';
END;
$$;

-- PASO 3: Crear función helper para obtener el company_id del admin actual
DROP FUNCTION IF EXISTS get_admin_company_id();

CREATE OR REPLACE FUNCTION get_admin_company_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
    v_company_id UUID;
BEGIN
    -- Obtener el company_id del usuario actual sin pasar por RLS
    SELECT company_id INTO v_company_id
    FROM users
    WHERE id = auth.uid() AND role = 'admin';
    
    RETURN v_company_id;
END;
$$;

-- PASO 4: Crear política usando las funciones helper (sin recursión)
-- Admin puede leer usuarios workers de su empresa
CREATE POLICY "Admin can read company worker users" ON users
    FOR SELECT
    USING (
        -- El usuario actual es admin
        is_admin()
        AND
        -- El usuario a leer es un worker de la misma empresa
        (
            -- Opción 1: El usuario tiene company_id y coincide con el del admin
            (
                users.company_id = get_admin_company_id()
                AND users.role = 'worker'
            )
            OR
            -- Opción 2: El usuario está asociado a un worker de la empresa del admin
            EXISTS (
                SELECT 1 FROM workers w
                WHERE w.user_id = users.id
                AND w.company_id = get_admin_company_id()
            )
        )
    );

-- PASO 5: Dar permisos de ejecución a las funciones
GRANT EXECUTE ON FUNCTION is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION is_admin() TO anon;
GRANT EXECUTE ON FUNCTION get_admin_company_id() TO authenticated;
GRANT EXECUTE ON FUNCTION get_admin_company_id() TO anon;

-- PASO 6: Verificar que la política se creó correctamente
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

-- PASO 7: Verificar que las funciones se crearon
SELECT 
    'Función creada' AS tipo,
    proname AS nombre
FROM pg_proc 
WHERE proname IN ('is_admin', 'get_admin_company_id');

-- ✅ LISTO! Ahora las políticas no causarán recursión infinita
-- Las funciones is_admin() y get_admin_company_id() usan SECURITY DEFINER
-- y pueden leer users sin pasar por las políticas RLS, evitando la recursión

