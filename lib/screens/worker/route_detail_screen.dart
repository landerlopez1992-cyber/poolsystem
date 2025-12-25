import 'package:flutter/material.dart';
import '../../models/route_model.dart';
import '../../services/route_service.dart';
import '../../services/client_service.dart';
import '../../models/client_model.dart';

class RouteDetailScreen extends StatefulWidget {
  final RouteModel route;

  const RouteDetailScreen({super.key, required this.route});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  final _routeService = RouteService();
  final _clientService = ClientService();
  final _notesController = TextEditingController();
  List<ClientModel> _clients = [];
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    try {
      if (widget.route.clientIds.isNotEmpty) {
        final clients = <ClientModel>[];
        for (final clientId in widget.route.clientIds) {
          try {
            final client = await _clientService.getClientById(clientId);
            if (client != null) {
              clients.add(client);
            }
          } catch (e) {
            // Continuar con el siguiente cliente
          }
        }
        setState(() {
          _clients = clients;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startRoute() async {
    try {
      setState(() {
        _isUpdating = true;
      });
      await _routeService.startRoute(widget.route.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruta iniciada')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _completeRoute() async {
    try {
      setState(() {
        _isUpdating = true;
      });
      await _routeService.completeRoute(widget.route.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruta completada')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _updateCompletedClients(int completed) async {
    try {
      setState(() {
        _isUpdating = true;
      });
      await _routeService.updateRoute(
        routeId: widget.route.id,
        completedClients: completed,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Información actualizada')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.route.name),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Información de la ruta
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de la Ruta',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C2C2C),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Fecha Programada',
                              _formatDate(widget.route.scheduledDate)),
                          if (widget.route.description != null)
                            _buildInfoRow(
                                'Descripción', widget.route.description!),
                          _buildInfoRow('Estado', _getStatusText(widget.route.status)),
                          if (widget.route.totalClients != null)
                            _buildInfoRow(
                                'Clientes',
                                '${widget.route.completedClients ?? 0}/${widget.route.totalClients}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Lista de clientes
                  if (_clients.isNotEmpty) ...[
                    Text(
                      'Clientes en la Ruta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._clients.map((client) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF4CAF50),
                              child: Text(
                                client.fullName[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              client.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            subtitle: Text(
                              client.address ?? 'Sin dirección',
                              style: const TextStyle(color: Color(0xFF666666)),
                            ),
                            trailing: Checkbox(
                              value: _clients.indexOf(client) <
                                  (widget.route.completedClients ?? 0),
                              onChanged: null,
                            ),
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],
                  // Actualizar progreso
                  if (widget.route.status == 'in_progress') ...[
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Actualizar Progreso',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Clientes completados: ${widget.route.completedClients ?? 0}/${widget.route.totalClients ?? 0}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: _isUpdating
                                      ? null
                                      : () {
                                          final current =
                                              widget.route.completedClients ?? 0;
                                          if (current > 0) {
                                            _updateCompletedClients(current - 1);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDC2626),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Icon(Icons.remove),
                                ),
                                ElevatedButton(
                                  onPressed: _isUpdating
                                      ? null
                                      : () {
                                          final current =
                                              widget.route.completedClients ?? 0;
                                          final total =
                                              widget.route.totalClients ?? 0;
                                          if (current < total) {
                                            _updateCompletedClients(current + 1);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Acciones
                  if (widget.route.status == 'scheduled')
                    ElevatedButton(
                      onPressed: _isUpdating ? null : _startRoute,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Iniciar Ruta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  if (widget.route.status == 'in_progress')
                    ElevatedButton(
                      onPressed: _isUpdating ? null : _completeRoute,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Completar Ruta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF2C2C2C)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Programada';
      case 'in_progress':
        return 'En Progreso';
      case 'completed':
        return 'Completada';
      default:
        return status;
    }
  }
}

