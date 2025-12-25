-- ============================================
-- FIX: Política RLS para INSERT de usuarios workers
-- ============================================
-- Este script permite que Super Admin pueda INSERTAR usuarios
-- cuando están creando/actualizando avatares de workers que no tienen
-- registro en la tabla users

-- Eliminar política existente si hay
DROP POLICY IF EXISTS "Super Admin can insert users" ON users;
DROP POLICY IF EXISTS "Super Admin can insert worker users" ON users;

-- Política: Super Admin puede INSERTAR usuarios
-- Esto permite crear usuarios cuando se actualiza un avatar de un worker
-- que no tiene registro en users pero sí en workers
CREATE POLICY "Super Admin can insert users" ON users
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- También permitir que Admin de empresa pueda insertar usuarios workers
-- cuando están creando workers desde su panel
CREATE POLICY "Company Admin can insert worker users" ON users
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.id = auth.uid() 
            AND u.role = 'admin'
            AND (
                -- El usuario a insertar debe ser un worker de la misma empresa
                EXISTS (
                    SELECT 1 FROM workers w
                    WHERE w.user_id = users.id
                    AND w.company_id = u.company_id
                )
                OR
                -- O el company_id del usuario a insertar debe coincidir con el del admin
                users.company_id = u.company_id
            )
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
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'users' 
AND cmd = 'INSERT'
ORDER BY policyname;

