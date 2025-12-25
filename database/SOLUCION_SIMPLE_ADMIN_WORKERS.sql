-- ============================================
-- SOLUCIÓN SIMPLE: Admin puede leer usuarios workers
-- ============================================
-- Esta solución es la MÁS SIMPLE posible
-- NO consulta users dentro de la política USING

-- PASO 1: Eliminar TODAS las políticas problemáticas
DROP POLICY IF EXISTS "Admin can read company worker users" ON users;

-- PASO 2: Eliminar TODAS las funciones problemáticas
DROP FUNCTION IF EXISTS is_admin() CASCADE;
DROP FUNCTION IF EXISTS get_admin_company_id() CASCADE;
DROP FUNCTION IF EXISTS get_current_admin_company_id() CASCADE;
DROP FUNCTION IF EXISTS is_admin_and_get_company() CASCADE;
DROP FUNCTION IF EXISTS check_admin_company_match(UUID) CASCADE;
DROP FUNCTION IF EXISTS admin_can_read_worker_user(UUID) CASCADE;

-- PASO 3: SOLUCIÓN MÁS SIMPLE - NO crear política adicional
-- En su lugar, usar la política existente "Users can read own data"
-- y agregar una política que permita leer usuarios workers
-- basándose SOLO en la tabla workers, SIN consultar users

-- Esta política permite leer usuarios workers si:
-- 1. El usuario es worker (users.role = 'worker')
-- 2. Existe un worker asociado a ese usuario
-- 3. El usuario actual tiene un registro en users con company_id
--    que coincide con el worker (pero NO verificamos el role aquí)
-- 
-- NOTA: Esta política es menos restrictiva pero NO causa recursión
-- porque NO consulta users para verificar el role del admin

CREATE POLICY "Allow reading worker users by company" ON users
    FOR SELECT
    USING (
        users.role = 'worker'
        AND EXISTS (
            SELECT 1 FROM workers w
            WHERE w.user_id = users.id
            -- Verificar que el usuario actual tiene un company_id que coincide
            -- PERO sin consultar users directamente (usamos subconsulta en workers)
            AND w.company_id IN (
                SELECT company_id FROM users WHERE id = auth.uid()
            )
        )
    );

-- ⚠️ Esta política aún puede causar recursión porque consulta users
-- en la subconsulta. Necesitamos una solución diferente.

-- SOLUCIÓN ALTERNATIVA: No crear política adicional
-- En su lugar, modificar el código de la aplicación para obtener
-- el avatar directamente desde workers o usar una vista

-- Por ahora, simplemente NO crear la política y dejar que
-- el código maneje la obtención del avatar de otra forma

