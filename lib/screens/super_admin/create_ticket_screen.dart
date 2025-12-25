import 'package:flutter/material.dart';
import '../../models/company_model.dart';
import '../../services/ticket_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/super_admin_layout.dart';

class CreateTicketScreen extends StatefulWidget {
  final List<CompanyModel> companies;

  const CreateTicketScreen({
    super.key,
    required this.companies,
  });

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ticketService = TicketService();
  final _authService = AuthService();
  
  String? _selectedCompanyId;
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'medium';
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una empresa')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      await _ticketService.createTicket(
        companyId: _selectedCompanyId!,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        createdBy: currentUser.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket creado exitosamente')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear ticket: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width > 600 ? 600.0 : double.infinity;

    return SuperAdminLayout(
      title: 'Crear Ticket de Soporte',
      selectedIndex: 2, // Soporte
      onItemSelected: (_) {},
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    color: Colors.white,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Empresa
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButtonFormField<String>(
                              value: _selectedCompanyId,
                              decoration: const InputDecoration(
                                labelText: 'Empresa *',
                                border: OutlineInputBorder(),
                              ),
                              items: widget.companies.map((company) {
                                return DropdownMenuItem(
                                  value: company.id,
                                  child: Text(company.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCompanyId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecciona una empresa';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Asunto
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _subjectController,
                              decoration: const InputDecoration(
                                labelText: 'Asunto *',
                                border: OutlineInputBorder(),
                                hintText: 'Resumen del problema o solicitud',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El asunto es requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Descripción
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Descripción *',
                                border: OutlineInputBorder(),
                                hintText: 'Describe el problema o solicitud en detalle',
                              ),
                              maxLines: 5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'La descripción es requerida';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Prioridad
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButtonFormField<String>(
                              value: _selectedPriority,
                              decoration: const InputDecoration(
                                labelText: 'Prioridad *',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'low',
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_downward, size: 16, color: Color(0xFF4CAF50)),
                                      SizedBox(width: 8),
                                      Text('Baja'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'medium',
                                  child: Row(
                                    children: [
                                      Icon(Icons.remove, size: 16, color: Color(0xFFFF9800)),
                                      SizedBox(width: 8),
                                      Text('Media'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'high',
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_upward, size: 16, color: Color(0xFFFF5722)),
                                      SizedBox(width: 8),
                                      Text('Alta'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'urgent',
                                  child: Row(
                                    children: [
                                      Icon(Icons.priority_high, size: 16, color: Color(0xFFDC2626)),
                                      SizedBox(width: 8),
                                      Text('Urgente'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedPriority = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botón
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Crear Ticket',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

