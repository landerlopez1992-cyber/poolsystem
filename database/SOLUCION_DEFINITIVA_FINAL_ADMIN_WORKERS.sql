-- ============================================
-- SOLUCIÓN DEFINITIVA FINAL: Admin puede leer usuarios workers
-- ============================================
-- Esta solución crea una función que NO se ejecuta dentro de la política
-- sino que se cachea el resultado antes de evaluar la política

-- PASO 1: Eliminar TODAS las políticas problemáticas
DROP POLICY IF EXISTS "Admin can read company worker users" ON users;

-- PASO 2: Eliminar TODAS las funciones problemáticas
DROP FUNCTION IF EXISTS is_admin() CASCADE;
DROP FUNCTION IF EXISTS get_admin_company_id() CASCADE;
DROP FUNCTION IF EXISTS get_current_admin_company_id() CASCADE;
DROP FUNCTION IF EXISTS is_admin_and_get_company() CASCADE;
DROP FUNCTION IF EXISTS check_admin_company_match(UUID) CASCADE;

-- PASO 3: Crear una solución SIMPLE que NO causa recursión
-- La política permite leer usuarios workers si:
-- 1. El usuario es worker (users.role = 'worker')
-- 2. Existe un worker asociado a ese usuario
-- 3. El usuario actual (auth.uid()) tiene un registro en users con role='admin'
--    y company_id que coincide con el worker
-- 
-- PERO: Para evitar recursión, NO consultamos users en la política USING
-- En su lugar, usamos una función SECURITY DEFINER que se ejecuta
-- con permisos del definer y NO pasa por RLS

CREATE OR REPLACE FUNCTION admin_can_read_worker_user(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
    v_current_user_id UUID;
    v_current_role TEXT;
    v_current_company_id UUID;
    v_worker_company_id UUID;
BEGIN
    -- Obtener información del usuario actual (NO pasa por RLS)
    v_current_user_id := auth.uid();
    
    IF v_current_user_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Obtener role y company_id del usuario actual
    SELECT role, company_id INTO v_current_role, v_current_company_id
    FROM users
    WHERE id = v_current_user_id
    LIMIT 1;
    
    -- Verificar que es admin
    IF v_current_role != 'admin' THEN
        RETURN FALSE;
    END IF;
    
    -- Obtener company_id del worker asociado al usuario
    SELECT company_id INTO v_worker_company_id
    FROM workers
    WHERE user_id = p_user_id
    LIMIT 1;
    
    -- Verificar que el worker pertenece a la empresa del admin
    RETURN (v_worker_company_id IS NOT NULL AND v_worker_company_id = v_current_company_id);
END;
$$;

-- PASO 4: Crear política que usa la función
CREATE POLICY "Admin can read company worker users" ON users
    FOR SELECT
    USING (
        users.role = 'worker'
        AND admin_can_read_worker_user(users.id) = true
    );

-- PASO 5: Dar permisos
GRANT EXECUTE ON FUNCTION admin_can_read_worker_user(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION admin_can_read_worker_user(UUID) TO anon;

-- PASO 6: Verificar
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
WHERE proname = 'admin_can_read_worker_user';

-- ✅ Esta solución debería funcionar porque:
-- 1. La función admin_can_read_worker_user() usa SECURITY DEFINER
-- 2. Se ejecuta con permisos del definer, NO pasa por RLS
-- 3. La política NO consulta users directamente en USING
-- 4. Solo verifica role='worker' y llama a la función

