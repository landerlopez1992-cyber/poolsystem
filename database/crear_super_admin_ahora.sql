-- ============================================
-- CREAR SUPER ADMIN - SCRIPT LISTO PARA EJECUTAR
-- ============================================
-- Este script está listo para ejecutar con tu ID de usuario

INSERT INTO users (id, email, full_name, role, is_active)
VALUES (
    'd430c58f-6373-4d13-9b10-47aaa4623946'::uuid,
    'landerlopez1992@gmail.com',
    'Super Admin',
    'super_admin',
    true
)
ON CONFLICT (id) DO UPDATE
SET role = 'super_admin', is_active = true;

-- ============================================
-- VERIFICAR QUE SE CREÓ CORRECTAMENTE:
-- ============================================
SELECT id, email, full_name, role, is_active, created_at
FROM users
WHERE id = 'd430c58f-6373-4d13-9b10-47aaa4623946'::uuid;

