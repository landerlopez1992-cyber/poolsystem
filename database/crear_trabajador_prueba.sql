-- ============================================
-- CREAR TRABAJADOR DE PRUEBA PARA APP MÓVIL
-- ============================================
-- Este script crea un trabajador completo para probar la app móvil

-- PASO 1: Crear una empresa de prueba (si no existe)
INSERT INTO companies (id, name, description, email, is_active)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'Empresa de Prueba',
    'Empresa para testing',
    'empresa@prueba.com',
    true
)
ON CONFLICT DO NOTHING;

-- PASO 2: Crear usuario en auth.users (debes hacerlo desde Authentication > Users en Supabase)
-- Email: trabajador@prueba.com
-- Password: (la que quieras)
-- Copia el ID del usuario que se crea

-- PASO 3: Reemplaza 'ID_DEL_USUARIO_AUTH' con el ID real del usuario que creaste
-- Luego ejecuta esto:

-- Insertar en tabla users
INSERT INTO users (id, email, full_name, role, company_id, is_active)
VALUES (
    'ID_DEL_USUARIO_AUTH'::uuid,  -- REEMPLAZA con el ID real
    'trabajador@prueba.com',
    'Trabajador Prueba',
    'worker',
    '00000000-0000-0000-0000-000000000001'::uuid,
    true
)
ON CONFLICT (id) DO UPDATE
SET role = 'worker', is_active = true;

-- Insertar en tabla workers
INSERT INTO workers (company_id, user_id, full_name, status)
VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'ID_DEL_USUARIO_AUTH'::uuid,  -- REEMPLAZA con el ID real
    'Trabajador Prueba',
    'active'
)
ON CONFLICT DO NOTHING;

-- Verificar
SELECT 
    u.id,
    u.email,
    u.full_name,
    u.role,
    w.id as worker_id,
    w.status
FROM users u
LEFT JOIN workers w ON w.user_id = u.id
WHERE u.email = 'trabajador@prueba.com';

