-- ============================================
-- SOLUCIÓN: Permitir a Super Admin crear usuarios
-- ============================================
-- Ejecuta este script en Supabase SQL Editor

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

-- Verificar que la política se creó
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'users' 
AND policyname = 'Super Admin can insert users';

-- Si ves la política listada arriba, ¡está lista!
-- Ahora intenta crear la empresa de nuevo

