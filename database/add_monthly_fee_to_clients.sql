-- ============================================
-- AGREGAR CAMPO MONTHLY_FEE A CLIENTS
-- ============================================
-- Este script agrega el campo monthly_fee (mensualidad) a la tabla clients
-- para que cada cliente pueda tener un precio mensual asociado

-- Agregar campo monthly_fee
ALTER TABLE clients
ADD COLUMN IF NOT EXISTS monthly_fee DECIMAL(10, 2) DEFAULT 0.00;

-- Agregar comentario al campo
COMMENT ON COLUMN clients.monthly_fee IS 'Mensualidad que paga el cliente (precio mensual)';

-- Actualizar clientes existentes con un valor por defecto (opcional)
-- UPDATE clients SET monthly_fee = 0.00 WHERE monthly_fee IS NULL;

-- Verificar que se agregó el campo
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'clients'
AND column_name = 'monthly_fee';

