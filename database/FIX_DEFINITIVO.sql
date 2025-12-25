-- ============================================
-- FIX DEFINITIVO: Asegurar que el usuario existe
-- ============================================
-- Ejecuta esto paso a paso

-- PASO 1: Ver el ID del usuario en auth.users
SELECT id, email FROM auth.users WHERE email = 'landerlopez1992@gmail.com';

-- PASO 2: Copia el ID que aparece arriba y reemplázalo en el siguiente INSERT
-- (El ID debería ser: d430c58f-6373-4d13-9b10-47aaa4623946)

-- PASO 3: Ejecuta esto con el ID correcto
INSERT INTO users (id, email, full_name, role, is_active)
VALUES (
    'd430c58f-6373-4d13-9b10-47aaa4623946'::uuid,  -- Asegúrate que este ID coincida con auth.users
    'landerlopez1992@gmail.com',
    'Super Admin',
    'super_admin',
    true
)
ON CONFLICT (id) DO UPDATE
SET 
    email = 'landerlopez1992@gmail.com',
    full_name = 'Super Admin',
    role = 'super_admin',
    is_active = true;

-- PASO 4: Verificar que ambos IDs coinciden
SELECT 
    au.id as auth_id,
    au.email as auth_email,
    u.id as user_id,
    u.email as user_email,
    u.role,
    u.is_active
FROM auth.users au
LEFT JOIN users u ON u.id = au.id
WHERE au.email = 'landerlopez1992@gmail.com';

-- Si auth_id y user_id son diferentes, ese es el problema
-- Debes actualizar el INSERT con el auth_id correcto

