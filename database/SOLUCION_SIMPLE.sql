-- ============================================
-- SOLUCIÓN SIMPLE - EJECUTA ESTO EN SUPABASE
-- ============================================

-- Paso 1: Crear el Super Admin en la tabla users
INSERT INTO users (id, email, full_name, role, is_active)
VALUES (
    'd430c58f-6373-4d13-9b10-47aaa4623946'::uuid,
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

-- Paso 2: Verificar que se creó
SELECT id, email, full_name, role, is_active
FROM users
WHERE email = 'landerlopez1992@gmail.com';

