-- ============================================
-- DEBUG: Verificar usuario en auth.users y users
-- ============================================

-- 1. Verificar en auth.users
SELECT 
    id,
    email,
    created_at
FROM auth.users
WHERE email = 'landerlopez1992@gmail.com';

-- 2. Verificar en tabla users
SELECT 
    id,
    email,
    full_name,
    role,
    is_active
FROM users
WHERE email = 'landerlopez1992@gmail.com';

-- 3. Comparar IDs - DEBEN SER IGUALES
-- Si los IDs son diferentes, ese es el problema

