-- ============================================
-- FIX: Insertar Super Admin en tabla users
-- ============================================
-- Ejecuta este script en Supabase SQL Editor

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

-- Verificar
SELECT id, email, full_name, role, is_active, created_at
FROM users
WHERE id = 'd430c58f-6373-4d13-9b10-47aaa4623946'::uuid;

