-- ============================================
-- FIX: Políticas RLS para tabla users
-- ============================================
-- Este script corrige las políticas para que los usuarios puedan leer su propia información

-- Eliminar políticas existentes (si hay)
DROP POLICY IF EXISTS "Users can read own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Super Admin can read all users" ON users;

-- Política: Los usuarios pueden leer su propia información
CREATE POLICY "Users can read own data" ON users
    FOR SELECT
    USING (auth.uid() = id);

-- Política: Los usuarios pueden actualizar su propia información
CREATE POLICY "Users can update own data" ON users
    FOR UPDATE
    USING (auth.uid() = id);

-- Política: Super Admin puede leer todos los usuarios
CREATE POLICY "Super Admin can read all users" ON users
    FOR SELECT
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
WHERE tablename = 'users';

