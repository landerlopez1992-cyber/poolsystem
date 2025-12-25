-- ============================================
-- SOLUCIÓN ÚLTIMA: Admin puede leer usuarios workers (SIN RECURSIÓN)
-- ============================================
-- Esta solución NO consulta users dentro de la política USING
-- Solo verifica workers y usa auth.uid() directamente

-- PASO 1: Eliminar TODAS las políticas problemáticas
DROP POLICY IF EXISTS "Admin can read company worker users" ON users;

-- PASO 2: Eliminar funciones problemáticas
DROP FUNCTION IF EXISTS is_admin() CASCADE;
DROP FUNCTION IF EXISTS get_admin_company_id() CASCADE;
DROP FUNCTION IF EXISTS get_current_admin_company_id() CASCADE;
DROP FUNCTION IF EXISTS is_admin_and_get_company() CASCADE;

-- PASO 3: La solución más simple: permitir que usuarios workers
-- sean leídos si existe un worker asociado y el usuario actual
-- tiene un registro en users con role='admin' y el mismo company_id
-- PERO sin consultar users dentro de la política USING

-- Opción A: Usar una función que cache el resultado
-- Esta función se ejecuta con SECURITY DEFINER y NO pasa por RLS
CREATE OR REPLACE FUNCTION check_admin_company_match(p_company_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
    v_current_company_id UUID;
    v_current_role TEXT;
BEGIN
    -- Obtener company_id y role del usuario actual
    -- Esta consulta NO pasa por RLS porque es SECURITY DEFINER
    SELECT company_id, role INTO v_current_company_id, v_current_role
    FROM users
    WHERE id = auth.uid()
    LIMIT 1;
    
    -- Verificar que es admin y que el company_id coincide
    RETURN (v_current_role = 'admin' AND v_current_company_id = p_company_id);
END;
$$;

-- PASO 4: Crear política que usa la función
CREATE POLICY "Admin can read company worker users" ON users
    FOR SELECT
    USING (
        users.role = 'worker'
        AND EXISTS (
            SELECT 1 FROM workers w
            WHERE w.user_id = users.id
            AND check_admin_company_match(w.company_id) = true
        )
    );

-- PASO 5: Dar permisos
GRANT EXECUTE ON FUNCTION check_admin_company_match(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION check_admin_company_match(UUID) TO anon;

-- PASO 6: Verificar
SELECT 
    'Política creada' as tipo,
    policyname as nombre,
    cmd as operacion
FROM pg_policies 
WHERE tablename = 'users' 
AND policyname = 'Admin can read company worker users';

-- ✅ Esta solución debería funcionar porque:
-- 1. La función check_admin_company_match() usa SECURITY DEFINER
-- 2. Se ejecuta con permisos del definer, NO pasa por RLS
-- 3. La política NO consulta users directamente
-- 4. Solo verifica workers y llama a la función

