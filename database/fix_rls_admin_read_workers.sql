-- ============================================
-- FIX: Política RLS para que Admins puedan leer usuarios workers
-- ============================================
-- Este script permite que los Admins (role='admin') puedan leer
-- los usuarios workers de su propia empresa para ver sus avatares

-- Política: Admin puede leer usuarios workers de su empresa
CREATE POLICY "Admin can read company worker users" ON users
    FOR SELECT
    USING (
        -- El usuario actual es admin
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.id = auth.uid() 
            AND u.role = 'admin'
        )
        AND
        -- El usuario a leer es un worker de la misma empresa
        (
            -- Opción 1: El usuario tiene company_id y coincide con el del admin
            EXISTS (
                SELECT 1 FROM users u
                WHERE u.id = auth.uid() 
                AND u.role = 'admin'
                AND users.company_id = u.company_id
                AND users.role = 'worker'
            )
            OR
            -- Opción 2: El usuario está asociado a un worker de la empresa del admin
            EXISTS (
                SELECT 1 FROM users u
                INNER JOIN workers w ON w.user_id = users.id
                WHERE u.id = auth.uid() 
                AND u.role = 'admin'
                AND w.company_id = u.company_id
            )
        )
    );

-- Verificar que la política se creó
SELECT 
    cmd,
    policyname,
    CASE 
        WHEN cmd = 'SELECT' THEN 'Lectura'
        ELSE cmd::text
    END as operacion
FROM pg_policies 
WHERE tablename = 'users' 
AND policyname = 'Admin can read company worker users';

