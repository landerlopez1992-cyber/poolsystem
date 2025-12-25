-- ============================================
-- TEST COMPLETO: Verificar todo
-- ============================================

-- 1. Verificar usuario en auth.users
SELECT 'auth.users' as tabla, id, email, created_at
FROM auth.users
WHERE email = 'landerlopez1992@gmail.com';

-- 2. Verificar usuario en tabla users
SELECT 'users' as tabla, id, email, full_name, role, is_active, created_at
FROM users
WHERE email = 'landerlopez1992@gmail.com';

-- 3. Verificar que los IDs coinciden
SELECT 
    au.id as auth_id,
    u.id as user_id,
    CASE 
        WHEN au.id = u.id THEN '✅ IDs COINCIDEN'
        ELSE '❌ IDs NO COINCIDEN - ESTE ES EL PROBLEMA'
    END as estado,
    u.role,
    u.is_active
FROM auth.users au
LEFT JOIN users u ON u.id = au.id
WHERE au.email = 'landerlopez1992@gmail.com';

-- 4. Si el estado dice "IDs NO COINCIDEN", ejecuta esto:
-- (Reemplaza AUTH_ID con el auth_id que aparece arriba)
/*
INSERT INTO users (id, email, full_name, role, is_active)
VALUES (
    'AUTH_ID'::uuid,  -- El auth_id del paso 3
    'landerlopez1992@gmail.com',
    'Super Admin',
    'super_admin',
    true
)
ON CONFLICT (id) DO UPDATE
SET role = 'super_admin', is_active = true;
*/

