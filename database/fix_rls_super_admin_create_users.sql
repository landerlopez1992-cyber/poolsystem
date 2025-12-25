-- ============================================
-- FIX: Permitir a Super Admin crear usuarios
-- ============================================
-- Este script corrige las políticas RLS para que Super Admin pueda crear usuarios

-- Eliminar políticas existentes de INSERT si hay
DROP POLICY IF EXISTS "Super Admin can insert users" ON users;
DROP POLICY IF EXISTS "Super Admin can create users" ON users;

-- Política: Super Admin puede INSERTAR usuarios
CREATE POLICY "Super Admin can insert users" ON users
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- Política: Super Admin puede LEER todos los usuarios
CREATE POLICY "Super Admin can read all users" ON users
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- Política: Super Admin puede ACTUALIZAR usuarios
CREATE POLICY "Super Admin can update users" ON users
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- Verificar que las políticas están activas
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'users'
ORDER BY policyname;

-- NOTA: También necesitas permitir que Super Admin pueda crear usuarios en auth.users
-- Esto se hace automáticamente si el usuario está autenticado como Super Admin
-- Pero asegúrate de que el usuario actual sea Super Admin cuando ejecutes esto

