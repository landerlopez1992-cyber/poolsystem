-- ============================================
-- FIX COMPLETO: Políticas RLS para tabla users
-- ============================================
-- Este script crea TODAS las políticas necesarias para que Super Admin
-- pueda leer, insertar y actualizar usuarios

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

-- PASO 2: Crear política para SELECT (leer usuarios)
CREATE POLICY "Super Admin can read all users" ON users
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role = 'super_admin'
        )
    );

-- PASO 3: Crear política para INSERT (crear usuarios)
CREATE POLICY "Super Admin can insert users" ON users
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role = 'super_admin'
        )
    );

-- PASO 4: Crear política para UPDATE (actualizar usuarios)
CREATE POLICY "Super Admin can update all users" ON users
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role = 'super_admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role = 'super_admin'
        )
    );

-- PASO 5: Verificar que todas las políticas se crearon
SELECT 
    cmd,
    policyname,
    with_check
FROM pg_policies 
WHERE tablename = 'users' 
AND policyname LIKE '%Super Admin%'
ORDER BY cmd, policyname;

-- PASO 6: Verificar que RLS está habilitado
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'users';

-- ✅ LISTO! Ahora Super Admin debería poder:
-- - Leer todos los usuarios (SELECT)
-- - Crear usuarios (INSERT)
-- - Actualizar usuarios (UPDATE)

