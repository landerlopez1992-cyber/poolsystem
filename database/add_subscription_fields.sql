-- ============================================
-- AGREGAR CAMPOS DE SUSCRIPCIÓN A COMPANIES
-- ============================================
-- Ejecuta este script en Supabase SQL Editor

-- Agregar campos de suscripción
ALTER TABLE companies
ADD COLUMN IF NOT EXISTS subscription_type VARCHAR(50) DEFAULT 'monthly',
ADD COLUMN IF NOT EXISTS subscription_price DECIMAL(10, 2) DEFAULT 250.00;

-- Agregar constraint para tipos de suscripción válidos
ALTER TABLE companies
ADD CONSTRAINT check_subscription_type 
CHECK (subscription_type IN ('monthly', 'lifetime'));

-- Actualizar empresas existentes con suscripción mensual por defecto
UPDATE companies
SET subscription_type = 'monthly', subscription_price = 250.00
WHERE subscription_type IS NULL;

-- Verificar que se agregaron los campos
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'companies'
AND column_name IN ('subscription_type', 'subscription_price', 'logo_url');

