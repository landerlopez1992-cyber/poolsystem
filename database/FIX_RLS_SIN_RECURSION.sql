-- ============================================
-- FIX: Políticas RLS sin recursión infinita
-- ============================================
-- El problema era que las políticas consultaban la tabla 'users' para verificar
-- el rol, causando recursión infinita. Esta solución usa una función helper
-- con SECURITY DEFINER para evitar la recursión.

-- PASO 1: Eliminar TODAS las políticas existentes de users
DROP POLICY IF EXISTS "Super Admin can insert users" ON users;
DROP POLICY IF EXISTS "Super Admin can insert worker users" ON users;
DROP POLICY IF EXISTS "Super Admin can create users" ON users;
DROP POLICY IF EXISTS "Super Admin can read all users" ON users;
DROP POLICY IF EXISTS "Super Admin can update users" ON users;
DROP POLICY IF EXISTS "Super Admin can update all users" ON users;
DROP POLICY IF EXISTS "Users can read own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Company Admin can insert worker users" ON users;

-- PASO 2: Crear función helper para verificar si el usuario actual es super_admin
-- Esta función usa SECURITY DEFINER para evitar problemas de RLS
DROP FUNCTION IF EXISTS is_super_admin();

CREATE OR REPLACE FUNCTION is_super_admin()
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
    
    RETURN v_user_role = 'super_admin';
END;
$$;

-- PASO 3: Crear políticas usando la función helper (sin recursión)
-- SELECT: Super Admin puede leer todos los usuarios
CREATE POLICY "Super Admin can read all users" ON users
    FOR SELECT
    USING (is_super_admin());

-- INSERT: Super Admin puede crear usuarios
CREATE POLICY "Super Admin can insert users" ON users
    FOR INSERT
    WITH CHECK (is_super_admin());

-- UPDATE: Super Admin puede actualizar todos los usuarios
CREATE POLICY "Super Admin can update all users" ON users
    FOR UPDATE
    USING (is_super_admin())
    WITH CHECK (is_super_admin());

-- PASO 4: Políticas para usuarios normales (pueden leer/actualizar sus propios datos)
CREATE POLICY "Users can read own data" ON users
    FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- PASO 5: Dar permisos de ejecución a la función
GRANT EXECUTE ON FUNCTION is_super_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION is_super_admin() TO anon;

-- PASO 6: Verificar que todas las políticas se crearon
SELECT 
    cmd,
    policyname,
    CASE 
        WHEN cmd = 'SELECT' THEN 'Lectura'
        WHEN cmd = 'INSERT' THEN 'Crear'
        WHEN cmd = 'UPDATE' THEN 'Actualizar'
        ELSE cmd::text
    END as operacion
FROM pg_policies 
WHERE tablename = 'users' 
ORDER BY cmd, policyname;

-- PASO 7: Verificar que la función se creó
SELECT 
    proname as nombre_funcion,
    prosrc as codigo
FROM pg_proc
WHERE proname = 'is_super_admin';

-- ✅ LISTO! Ahora las políticas no causarán recursión infinita
-- La función is_super_admin() usa SECURITY DEFINER y puede leer users
-- sin pasar por las políticas RLS, evitando la recursión

