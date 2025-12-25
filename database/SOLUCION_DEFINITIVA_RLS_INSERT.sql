-- ============================================
-- SOLUCIÓN DEFINITIVA: Política RLS para INSERT
-- ============================================
-- Este script crea una política que DEBE funcionar
-- Si aún falla, el problema puede ser de autenticación

-- PASO 1: Eliminar TODAS las políticas de INSERT
DROP POLICY IF EXISTS "Super Admin can insert users" ON users;
DROP POLICY IF EXISTS "Super Admin can insert worker users" ON users;
DROP POLICY IF EXISTS "Super Admin can create users" ON users;
DROP POLICY IF EXISTS "Company Admin can insert worker users" ON users;

-- PASO 2: Verificar que el usuario actual es Super Admin
DO $$
DECLARE
    current_user_id UUID;
    current_user_role TEXT;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'No hay usuario autenticado. Asegúrate de estar logueado en Supabase.';
    END IF;
    
    SELECT role INTO current_user_role
    FROM users
    WHERE id = current_user_id;
    
    IF current_user_role IS NULL THEN
        RAISE EXCEPTION 'El usuario actual no existe en la tabla users. ID: %', current_user_id;
    END IF;
    
    IF current_user_role != 'super_admin' THEN
        RAISE EXCEPTION 'El usuario actual NO es Super Admin. Rol actual: %. ID: %', current_user_role, current_user_id;
    END IF;
    
    RAISE NOTICE '✅ Usuario verificado: Super Admin (ID: %)', current_user_id;
END $$;

-- PASO 3: Crear política usando SECURITY DEFINER (más permisiva)
-- Esta política permite INSERT si el usuario actual es super_admin
CREATE POLICY "Super Admin can insert users" ON users
    FOR INSERT
    WITH CHECK (
        -- Verificar que el usuario actual es super_admin
        -- Usamos una subconsulta simple
        (SELECT role FROM users WHERE id = auth.uid()) = 'super_admin'
    );

-- PASO 4: Verificar que la política se creó
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    with_check
FROM pg_policies 
WHERE tablename = 'users' 
AND cmd = 'INSERT'
AND policyname = 'Super Admin can insert users';

-- PASO 5: Si aún falla, crear una función con SECURITY DEFINER
-- Esta función tiene permisos elevados y puede insertar sin problemas de RLS
CREATE OR REPLACE FUNCTION create_user_for_worker(
    p_user_id UUID,
    p_email TEXT,
    p_full_name TEXT,
    p_company_id UUID,
    p_phone TEXT DEFAULT NULL,
    p_avatar_url TEXT DEFAULT NULL
)
RETURNS users
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_current_user_role TEXT;
    v_new_user users;
BEGIN
    -- Verificar que el usuario actual es super_admin
    SELECT role INTO v_current_user_role
    FROM users
    WHERE id = auth.uid();
    
    IF v_current_user_role != 'super_admin' THEN
        RAISE EXCEPTION 'Solo Super Admin puede crear usuarios';
    END IF;
    
    -- Insertar el usuario
    INSERT INTO users (id, email, full_name, role, company_id, phone, avatar_url, is_active)
    VALUES (p_user_id, p_email, p_full_name, 'worker', p_company_id, p_phone, p_avatar_url, true)
    RETURNING * INTO v_new_user;
    
    RETURN v_new_user;
END;
$$;

-- PASO 6: Dar permisos de ejecución a la función
GRANT EXECUTE ON FUNCTION create_user_for_worker TO authenticated;

-- NOTA: Si la política directa no funciona, puedes usar esta función
-- desde la aplicación Flutter llamando:
-- SELECT * FROM create_user_for_worker(...)

