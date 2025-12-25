-- ============================================
-- TABLA: support_tickets
-- Sistema de tickets de soporte para Super Admin
-- ============================================

-- Crear tabla de tickets de soporte
CREATE TABLE IF NOT EXISTS support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'open',
    priority VARCHAR(50) NOT NULL DEFAULT 'medium',
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,
    closed_by UUID REFERENCES users(id) ON DELETE SET NULL
);

-- Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_support_tickets_company_id ON support_tickets(company_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_status ON support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_support_tickets_priority ON support_tickets(priority);
CREATE INDEX IF NOT EXISTS idx_support_tickets_created_at ON support_tickets(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_support_tickets_created_by ON support_tickets(created_by);

-- Agregar constraint para validar status
ALTER TABLE support_tickets 
ADD CONSTRAINT chk_support_tickets_status 
CHECK (status IN ('open', 'in_progress', 'closed'));

-- Agregar constraint para validar priority
ALTER TABLE support_tickets 
ADD CONSTRAINT chk_support_tickets_priority 
CHECK (priority IN ('low', 'medium', 'high', 'urgent'));

-- Crear trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_support_tickets_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS set_support_tickets_updated_at ON support_tickets;
CREATE TRIGGER set_support_tickets_updated_at
BEFORE UPDATE ON support_tickets
FOR EACH ROW
EXECUTE FUNCTION update_support_tickets_updated_at();

-- ============================================
-- POLÍTICAS RLS (Row Level Security)
-- ============================================

-- Habilitar RLS
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;

-- Política: Super Admin puede ver todos los tickets
CREATE POLICY "Super Admin can view all tickets" ON support_tickets
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- Política: Super Admin puede crear tickets
CREATE POLICY "Super Admin can create tickets" ON support_tickets
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- Política: Super Admin puede actualizar tickets
CREATE POLICY "Super Admin can update tickets" ON support_tickets
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- Política: Super Admin puede eliminar tickets (opcional)
CREATE POLICY "Super Admin can delete tickets" ON support_tickets
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- ============================================
-- COMENTARIOS
-- ============================================

COMMENT ON TABLE support_tickets IS 'Tickets de soporte para comunicación entre Super Admin y empresas';
COMMENT ON COLUMN support_tickets.status IS 'Estado del ticket: open, in_progress, closed';
COMMENT ON COLUMN support_tickets.priority IS 'Prioridad: low, medium, high, urgent';

