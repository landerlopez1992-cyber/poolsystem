-- ============================================
-- DIAGNÓSTICO: Verificar políticas RLS de users
-- ============================================
-- Este script lista TODAS las políticas RLS de la tabla users
-- para identificar posibles conflictos

-- 1. Verificar que RLS está habilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'users';

-- 2. Listar TODAS las políticas de users
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
ORDER BY cmd, policyname;

-- 3. Verificar el usuario actual y su rol
SELECT 
    id,
    email,
    role,
    is_active
FROM users
WHERE id = auth.uid();

-- 4. Verificar si hay políticas duplicadas o conflictivas
SELECT 
    cmd,
    COUNT(*) as total_policies,
    STRING_AGG(policyname, ', ') as policy_names
FROM pg_policies
WHERE tablename = 'users'
GROUP BY cmd
ORDER BY cmd;

-- 5. Intentar un INSERT de prueba (comentado para no ejecutar accidentalmente)
-- Descomenta esto SOLO si quieres probar manualmente:
/*
INSERT INTO users (id, email, full_name, role, is_active)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'test@example.com',
    'Test User',
    'worker',
    true
);
*/

