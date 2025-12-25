-- ============================================
-- CREAR USUARIO SUPER ADMIN
-- ============================================
-- INSTRUCCIONES:
-- 1. Primero crea el usuario en Authentication > Users en el dashboard de Supabase
-- 2. Copia el ID del usuario que aparece en la lista
-- 3. Reemplaza 'AQUI_VA_EL_ID_DEL_USUARIO' con el ID real
-- 4. Ejecuta este script

-- Opción 1: Si ya creaste el usuario en Authentication, solo inserta en la tabla users
-- Reemplaza 'AQUI_VA_EL_ID_DEL_USUARIO' con el UUID del usuario de auth.users
INSERT INTO users (id, email, full_name, role, is_active)
VALUES (
    'AQUI_VA_EL_ID_DEL_USUARIO'::uuid,  -- Reemplaza con el ID real del usuario
    'tu-email@ejemplo.com',              -- Reemplaza con tu email
    'Super Admin',                       -- Tu nombre
    'super_admin',
    true
)
ON CONFLICT (id) DO UPDATE
SET role = 'super_admin', is_active = true;

-- ============================================
-- ALTERNATIVA: Si quieres crear el usuario directamente desde SQL
-- ============================================
-- NOTA: Esto requiere permisos especiales y puede no funcionar en todos los casos
-- Es mejor crear el usuario desde el dashboard de Authentication

-- Primero crear en auth.users (esto puede requerir permisos especiales)
-- INSERT INTO auth.users (
--     id,
--     instance_id,
--     email,
--     encrypted_password,
--     email_confirmed_at,
--     created_at,
--     updated_at,
--     raw_app_meta_data,
--     raw_user_meta_data,
--     is_super_admin,
--     role
-- )
-- VALUES (
--     gen_random_uuid(),
--     '00000000-0000-0000-0000-000000000000'::uuid,
--     'tu-email@ejemplo.com',
--     crypt('tu-password-aqui', gen_salt('bf')),
--     NOW(),
--     NOW(),
--     NOW(),
--     '{"provider":"email","providers":["email"]}',
--     '{}',
--     false,
--     'authenticated'
-- );

-- ============================================
-- MÉTODO RECOMENDADO (Paso a paso):
-- ============================================
-- 1. Ve a Authentication > Users en Supabase Dashboard
-- 2. Haz clic en "Add user" o "Invite user"
-- 3. Ingresa tu email y contraseña
-- 4. Copia el ID del usuario (aparece en la lista de usuarios)
-- 5. Ejecuta este script reemplazando 'AQUI_VA_EL_ID_DEL_USUARIO' con el ID copiado

-- Ejemplo de cómo se ve un UUID válido:
-- '550e8400-e29b-41d4-a716-446655440000'

-- ============================================
-- VERIFICAR QUE EL USUARIO FUE CREADO CORRECTAMENTE:
-- ============================================
-- SELECT id, email, full_name, role, is_active, created_at
-- FROM users
-- WHERE role = 'super_admin';

