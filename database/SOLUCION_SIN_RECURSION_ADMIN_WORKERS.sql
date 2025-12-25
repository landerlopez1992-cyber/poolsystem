-- ============================================
-- SOLUCIÓN SIN RECURSIÓN: Admin puede leer usuarios workers
-- ============================================
-- Esta solución NO consulta users dentro de la política USING
-- Usa una función SECURITY DEFINER que se ejecuta con permisos elevados

-- PASO 1: Eliminar TODAS las políticas problemáticas
DROP POLICY IF EXISTS "Admin can read company worker users" ON users;

-- PASO 2: Eliminar funciones problemáticas
DROP FUNCTION IF EXISTS is_admin() CASCADE;
DROP FUNCTION IF EXISTS get_admin_company_id() CASCADE;
DROP FUNCTION IF EXISTS get_current_admin_company_id() CASCADE;

-- PASO 3: Crear función que verifica si el usuario actual es admin
-- y devuelve su company_id. Usa SECURITY DEFINER para evitar RLS
CREATE OR REPLACE FUNCTION is_admin_and_get_company()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
    v_company_id UUID;
    v_role TEXT;
BEGIN
    -- Esta consulta NO pasa por RLS porque es SECURITY DEFINER
    SELECT company_id, role INTO v_company_id, v_role
    FROM users
    WHERE id = auth.uid()
    LIMIT 1;
    
    -- Solo devolver company_id si es admin
    IF v_role = 'admin' THEN
        RETURN v_company_id;
    ELSE
        RETURN NULL;
    END IF;
END;
$$;

-- PASO 4: Crear política que usa la función
-- La política NO consulta users directamente, solo usa la función
CREATE POLICY "Admin can read company worker users" ON users
    FOR SELECT
    USING (
        -- Solo usuarios workers
        users.role = 'worker'
        AND
        -- Verificar que existe un worker asociado a este usuario
        -- Y que ese worker pertenece a la empresa del admin
        EXISTS (
            SELECT 1 FROM workers w
            WHERE w.user_id = users.id
            AND w.company_id = is_admin_and_get_company()
        )
    );

-- PASO 5: Dar permisos de ejecución
GRANT EXECUTE ON FUNCTION is_admin_and_get_company() TO authenticated;
GRANT EXECUTE ON FUNCTION is_admin_and_get_company() TO anon;

-- PASO 6: Verificar que se creó
SELECT 
    'Política creada' as tipo,
    policyname as nombre
FROM pg_policies 
WHERE tablename = 'users' 
AND policyname = 'Admin can read company worker users';

SELECT 
    'Función creada' as tipo,
    proname as nombre
FROM pg_proc 
WHERE proname = 'is_admin_and_get_company';

-- ✅ LISTO! 
-- La función is_admin_and_get_company() usa SECURITY DEFINER
-- y se ejecuta con permisos del definer, NO pasa por RLS.
-- Por lo tanto, NO causa recursión infinita.

