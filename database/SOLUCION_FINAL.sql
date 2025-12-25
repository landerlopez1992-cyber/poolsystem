-- ============================================
-- SOLUCIÓN FINAL - EJECUTA ESTO
-- ============================================

-- PASO 1: Ver el ID REAL del usuario en auth.users
SELECT id, email FROM auth.users WHERE email = 'landerlopez1992@gmail.com';

-- PASO 2: Copia el ID que aparece arriba (debe ser algo como: d430c58f-6373-4d13-9b10-47aaa4623946)

-- PASO 3: Reemplaza 'AQUI_VA_EL_ID_REAL' con el ID que copiaste y ejecuta:
INSERT INTO users (id, email, full_name, role, is_active)
VALUES (
    'AQUI_VA_EL_ID_REAL'::uuid,  -- Pega el ID del PASO 1 aquí
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
    'auth.users ID' as tabla,
    id,
    email
FROM auth.users
WHERE email = 'landerlopez1992@gmail.com'

UNION ALL

SELECT 
    'users ID' as tabla,
    id,
    email
FROM users
WHERE email = 'landerlopez1992@gmail.com';

-- Si los IDs son diferentes, ese es el problema
-- Los IDs DEBEN ser exactamente iguales

