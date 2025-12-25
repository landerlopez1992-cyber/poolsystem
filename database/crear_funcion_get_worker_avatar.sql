-- ============================================
-- SOLUCIÓN: Función RPC para obtener avatar de worker
-- ============================================
-- En lugar de crear una política RLS compleja que causa recursión,
-- creamos una función RPC que obtiene el avatar directamente

-- PASO 1: Eliminar políticas problemáticas
DROP POLICY IF EXISTS "Admin can read company worker users" ON users;

-- PASO 2: Crear función RPC que obtiene el avatar de un worker
-- Esta función NO pasa por RLS porque es SECURITY DEFINER
CREATE OR REPLACE FUNCTION get_worker_avatar(p_user_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
    v_avatar_url TEXT;
    v_current_user_id UUID;
    v_current_role TEXT;
    v_current_company_id UUID;
    v_worker_company_id UUID;
BEGIN
    -- Obtener información del usuario actual (NO pasa por RLS)
    v_current_user_id := auth.uid();
    
    IF v_current_user_id IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Verificar que el usuario actual es admin
    SELECT role, company_id INTO v_current_role, v_current_company_id
    FROM users
    WHERE id = v_current_user_id
    LIMIT 1;
    
    IF v_current_role != 'admin' THEN
        RETURN NULL;
    END IF;
    
    -- Verificar que el worker pertenece a la empresa del admin
    SELECT company_id INTO v_worker_company_id
    FROM workers
    WHERE user_id = p_user_id
    LIMIT 1;
    
    IF v_worker_company_id IS NULL OR v_worker_company_id != v_current_company_id THEN
        RETURN NULL;
    END IF;
    
    -- Obtener el avatar del usuario worker
    SELECT avatar_url INTO v_avatar_url
    FROM users
    WHERE id = p_user_id
    LIMIT 1;
    
    RETURN v_avatar_url;
END;
$$;

-- PASO 3: Dar permisos
GRANT EXECUTE ON FUNCTION get_worker_avatar(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_worker_avatar(UUID) TO anon;

-- PASO 4: Verificar
SELECT 
    'Función creada' as tipo,
    proname as nombre
FROM pg_proc 
WHERE proname = 'get_worker_avatar';

-- ✅ Esta función se puede llamar desde el código de la aplicación
-- y NO causa recursión porque es SECURITY DEFINER y NO se ejecuta
-- dentro de una política RLS

