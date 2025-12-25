-- ============================================
-- VERIFICAR QUE EL SUPER ADMIN SE CREÓ
-- ============================================
-- Ejecuta esto para confirmar que todo está bien

SELECT 
    id, 
    email, 
    full_name, 
    role, 
    is_active,
    created_at
FROM users
WHERE email = 'landerlopez1992@gmail.com';

-- Deberías ver una fila con:
-- email: landerlopez1992@gmail.com
-- role: super_admin
-- is_active: true

