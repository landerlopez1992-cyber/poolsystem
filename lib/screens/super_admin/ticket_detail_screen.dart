import 'package:flutter/material.dart';
import '../../models/ticket_model.dart';
import '../../services/ticket_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/super_admin_layout.dart';

class TicketDetailScreen extends StatefulWidget {
  final TicketModel ticket;

  const TicketDetailScreen({
    super.key,
    required this.ticket,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _ticketService = TicketService();
  final _authService = AuthService();
  late TicketModel _ticket;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final updatedTicket = await _ticketService.updateTicketStatus(
        ticketId: _ticket.id,
        status: newStatus,
        updatedBy: currentUser.id,
      );

      setState(() {
        _ticket = updatedTicket;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'closed'
                  ? 'Ticket cerrado'
                  : 'Estado actualizado',
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<void> _confirmCloseTicket() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Ticket'),
        content: const Text('¿Estás seguro de que deseas cerrar este ticket?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _updateStatus('closed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width > 800 ? 800.0 : double.infinity;

    return SuperAdminLayout(
      title: 'Detalle del Ticket',
      selectedIndex: 2, // Soporte
      onItemSelected: (_) {},
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con estado y prioridad
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _ticket.subject,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C2C2C),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _ticket.companyName ?? 'Empresa desconocida',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Badges
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Color(_ticket.statusColor).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(_ticket.statusColor),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _ticket.statusLabel,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(_ticket.statusColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Color(_ticket.priorityColor).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _ticket.priorityLabel,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(_ticket.priorityColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        // Descripción
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _ticket.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                            height: 1.5,
                          ),
                        ),
                        const Divider(height: 32),
                        // Información adicional
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                'Creado',
                                _formatDate(_ticket.createdAt),
                                Icons.calendar_today,
                              ),
                            ),
                            if (_ticket.updatedAt != null)
                              Expanded(
                                child: _buildInfoItem(
                                  'Actualizado',
                                  _formatDate(_ticket.updatedAt!),
                                  Icons.update,
                                ),
                              ),
                            if (_ticket.closedAt != null)
                              Expanded(
                                child: _buildInfoItem(
                                  'Cerrado',
                                  _formatDate(_ticket.closedAt!),
                                  Icons.check_circle,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Botones de acción
                if (_ticket.status != 'closed')
                  Row(
                    children: [
                      if (_ticket.status == 'open')
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () => _updateStatus('in_progress'),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Marcar en Progreso'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9800),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ),
                      if (_ticket.status == 'open') const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _confirmCloseTicket,
                            icon: const Icon(Icons.close),
                            label: const Text('Cerrar Ticket'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

