-- ============================================
-- TABLA: ticket_messages
-- Mensajes dentro de los tickets de soporte
-- ============================================

-- Crear tabla de mensajes de tickets
CREATE TABLE IF NOT EXISTS ticket_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_read BOOLEAN DEFAULT false
);

-- Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_ticket_messages_ticket_id ON ticket_messages(ticket_id);
CREATE INDEX IF NOT EXISTS idx_ticket_messages_sender_id ON ticket_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_ticket_messages_created_at ON ticket_messages(created_at DESC);

-- Crear trigger para actualizar updated_at del ticket cuando se envía un mensaje
CREATE OR REPLACE FUNCTION update_ticket_on_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE support_tickets
    SET updated_at = NOW()
    WHERE id = NEW.ticket_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS set_ticket_updated_on_message ON ticket_messages;
CREATE TRIGGER set_ticket_updated_on_message
AFTER INSERT ON ticket_messages
FOR EACH ROW
EXECUTE FUNCTION update_ticket_on_message();

-- ============================================
-- POLÍTICAS RLS (Row Level Security)
-- ============================================

-- Habilitar RLS
ALTER TABLE ticket_messages ENABLE ROW LEVEL SECURITY;

-- Política: Super Admin puede ver todos los mensajes
CREATE POLICY "Super Admin can view all messages" ON ticket_messages
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- Política: Admin puede ver mensajes de tickets de su empresa
CREATE POLICY "Admin can view messages of their company tickets" ON ticket_messages
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
            AND EXISTS (
                SELECT 1 FROM support_tickets
                WHERE support_tickets.id = ticket_messages.ticket_id
                AND support_tickets.company_id = users.company_id
            )
        )
    );

-- Política: Super Admin puede enviar mensajes
CREATE POLICY "Super Admin can send messages" ON ticket_messages
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
        AND sender_id = auth.uid()
    );

-- Política: Admin puede enviar mensajes en tickets de su empresa
CREATE POLICY "Admin can send messages in their company tickets" ON ticket_messages
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
            AND EXISTS (
                SELECT 1 FROM support_tickets
                WHERE support_tickets.id = ticket_messages.ticket_id
                AND support_tickets.company_id = users.company_id
            )
        )
        AND sender_id = auth.uid()
    );

-- Política: Super Admin puede actualizar mensajes (marcar como leídos)
CREATE POLICY "Super Admin can update messages" ON ticket_messages
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'super_admin'
        )
    );

-- Política: Admin puede actualizar mensajes de sus tickets
CREATE POLICY "Admin can update messages of their tickets" ON ticket_messages
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
            AND EXISTS (
                SELECT 1 FROM support_tickets
                WHERE support_tickets.id = ticket_messages.ticket_id
                AND support_tickets.company_id = users.company_id
            )
        )
    );

-- ============================================
-- COMENTARIOS
-- ============================================

COMMENT ON TABLE ticket_messages IS 'Mensajes de chat dentro de los tickets de soporte';
COMMENT ON COLUMN ticket_messages.is_read IS 'Indica si el mensaje ha sido leído por el destinatario';

