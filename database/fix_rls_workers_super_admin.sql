-- ============================================
-- FIX: Políticas RLS para tabla workers
-- ============================================
-- Este script permite al Super Admin crear y gestionar workers

-- Eliminar políticas existentes de workers si hay
DROP POLICY IF EXISTS "Super Admin can view all workers" ON workers;
DROP POLICY IF EXISTS "Super Admin can insert workers" ON workers;
DROP POLICY IF EXISTS "Super Admin can update workers" ON workers;
DROP POLICY IF EXISTS "Super Admin can delete workers" ON workers;
DROP POLICY IF EXISTS "Admin can view own company workers" ON workers;
DROP POLICY IF EXISTS "Admin can insert own company workers" ON workers;
DROP POLICY IF EXISTS "Admin can update own company workers" ON workers;

-- Política: Super Admin puede ver todos los workers
CREATE POLICY "Super Admin can view all workers" ON workers
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- Política: Super Admin puede insertar workers
CREATE POLICY "Super Admin can insert workers" ON workers
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- Política: Super Admin puede actualizar workers
CREATE POLICY "Super Admin can update workers" ON workers
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- Política: Super Admin puede eliminar workers
CREATE POLICY "Super Admin can delete workers" ON workers
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- Política: Admin puede ver workers de su empresa
CREATE POLICY "Admin can view own company workers" ON workers
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
            AND users.company_id = workers.company_id
        )
    );

-- Política: Admin puede insertar workers de su empresa
CREATE POLICY "Admin can insert own company workers" ON workers
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
            AND users.company_id = workers.company_id
        )
    );

-- Política: Admin puede actualizar workers de su empresa
CREATE POLICY "Admin can update own company workers" ON workers
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
            AND users.company_id = workers.company_id
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
            AND users.company_id = workers.company_id
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
WHERE tablename = 'workers'
ORDER BY policyname;

