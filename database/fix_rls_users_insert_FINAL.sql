-- ============================================
-- FIX FINAL: Política RLS para INSERT de usuarios
-- ============================================
-- Este script crea una política más simple y directa para permitir
-- que Super Admin pueda INSERTAR usuarios

-- PASO 1: Eliminar TODAS las políticas de INSERT existentes
DROP POLICY IF EXISTS "Super Admin can insert users" ON users;
DROP POLICY IF EXISTS "Super Admin can insert worker users" ON users;
DROP POLICY IF EXISTS "Super Admin can create users" ON users;

-- PASO 2: Verificar que el usuario actual es Super Admin
-- Primero, verificar que existe y tiene el rol correcto
DO $$
DECLARE
    current_user_id UUID;
    current_user_role TEXT;
BEGIN
    -- Obtener el ID del usuario actual
    current_user_id := auth.uid();
    
    -- Obtener el rol del usuario actual
    SELECT role INTO current_user_role
    FROM users
    WHERE id = current_user_id;
    
    -- Si no es super_admin, mostrar advertencia
    IF current_user_role != 'super_admin' THEN
        RAISE NOTICE 'ADVERTENCIA: El usuario actual no es Super Admin. Rol actual: %', current_user_role;
        RAISE NOTICE 'Asegúrate de estar autenticado como Super Admin antes de ejecutar este script.';
    ELSE
        RAISE NOTICE 'Usuario verificado: Super Admin';
    END IF;
END $$;

-- PASO 3: Crear política simple para Super Admin INSERT
-- Esta política permite que cualquier usuario autenticado que sea super_admin
-- pueda insertar en la tabla users
CREATE POLICY "Super Admin can insert users" ON users
    FOR INSERT
    WITH CHECK (
        -- Verificar que el usuario actual es super_admin
        EXISTS (
            SELECT 1 
            FROM users 
            WHERE id = auth.uid() 
            AND role = 'super_admin'
        )
    );

-- PASO 4: Verificar que la política se creó correctamente
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

-- PASO 5: Verificar que RLS está habilitado
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'users';

-- NOTA: Si aún falla, puede ser que necesites verificar:
-- 1. Que estás autenticado como Super Admin en Supabase
-- 2. Que el usuario Super Admin existe en la tabla users
-- 3. Que no hay otras políticas más restrictivas bloqueando el INSERT

