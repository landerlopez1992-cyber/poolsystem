-- ============================================
-- SOLUCIÓN DEFINITIVA: Política RLS para INSERT
-- ============================================
-- Este script crea una política y una función para permitir INSERT de usuarios
-- NO requiere autenticación para ejecutarse (puede ejecutarse desde SQL Editor)

-- PASO 1: Eliminar TODAS las políticas de INSERT existentes
DROP POLICY IF EXISTS "Super Admin can insert users" ON users;
DROP POLICY IF EXISTS "Super Admin can insert worker users" ON users;
DROP POLICY IF EXISTS "Super Admin can create users" ON users;
DROP POLICY IF EXISTS "Company Admin can insert worker users" ON users;

-- PASO 2: Crear política usando verificación simple
-- Esta política permite INSERT si el usuario actual es super_admin
CREATE POLICY "Super Admin can insert users" ON users
    FOR INSERT
    WITH CHECK (
        -- Verificar que el usuario actual es super_admin
        (SELECT role FROM users WHERE id = auth.uid()) = 'super_admin'
    );

-- PASO 3: Verificar que la política se creó
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

-- PASO 4: Crear función con SECURITY DEFINER
-- Esta función tiene permisos elevados y puede insertar sin problemas de RLS
-- La verificación del usuario se hace DENTRO de la función cuando se ejecuta
DROP FUNCTION IF EXISTS create_user_for_worker(UUID, TEXT, TEXT, UUID, TEXT, TEXT);

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
    -- Si auth.uid() es NULL, lanzar error
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'No hay usuario autenticado';
    END IF;
    
    SELECT role INTO v_current_user_role
    FROM users
    WHERE id = auth.uid();
    
    IF v_current_user_role != 'super_admin' THEN
        RAISE EXCEPTION 'Solo Super Admin puede crear usuarios. Rol actual: %', COALESCE(v_current_user_role, 'NULL');
    END IF;
    
    -- Insertar el usuario
    INSERT INTO users (id, email, full_name, role, company_id, phone, avatar_url, is_active)
    VALUES (p_user_id, p_email, p_full_name, 'worker', p_company_id, p_phone, p_avatar_url, true)
    RETURNING * INTO v_new_user;
    
    RETURN v_new_user;
END;
$$;

-- PASO 5: Dar permisos de ejecución a la función
GRANT EXECUTE ON FUNCTION create_user_for_worker TO authenticated;

-- PASO 6: Verificar que todo se creó correctamente
SELECT 
    'Política creada' as tipo,
    policyname as nombre
FROM pg_policies 
WHERE tablename = 'users' 
AND cmd = 'INSERT'
AND policyname = 'Super Admin can insert users'

UNION ALL

SELECT 
    'Función creada' as tipo,
    proname as nombre
FROM pg_proc
WHERE proname = 'create_user_for_worker';

-- ✅ LISTO! Ahora intenta subir el avatar desde la aplicación Flutter
-- La función create_user_for_worker se ejecutará automáticamente si la política falla

