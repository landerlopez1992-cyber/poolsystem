import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/route_service.dart';
import '../../services/worker_service.dart';
import '../../models/route_model.dart';
import '../../models/worker_model.dart';
import 'route_detail_screen.dart';
import 'worker_profile_screen.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  final _authService = AuthService();
  final _routeService = RouteService();
  final _workerService = WorkerService();
  
  List<RouteModel> _routes = [];
  WorkerModel? _worker;
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        // Obtener información del trabajador
        final worker = await _workerService.getWorkerByUserId(user.id);
        setState(() {
          _worker = worker;
        });

        if (worker != null) {
          await _loadRoutes(worker.id);
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRoutes(String workerId) async {
    try {
      final routes = await _routeService.getRoutesByWorker(workerId);
      setState(() {
        _routes = routes;
      });
    } catch (e) {
      // Error silencioso
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Panel Trabajador'),
          backgroundColor: const Color(0xFF37474F),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(_worker?.fullName ?? 'Panel Trabajador'),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WorkerProfileScreen(worker: _worker!),
                ),
              );
              _loadData(); // Recargar datos por si actualizó foto
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildRoutesTab(),
          _buildScheduleTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFFFF9800),
        unselectedItemColor: const Color(0xFF666666),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.route),
            label: 'Rutas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesTab() {
    return RefreshIndicator(
      onRefresh: () => _loadData(),
      child: _routes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay rutas asignadas',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _routes.length,
              itemBuilder: (context, index) {
                final route = _routes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(route.status),
                      child: Icon(
                        _getStatusIcon(route.status),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      route.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(route.scheduledDate),
                          style: const TextStyle(color: Color(0xFF666666)),
                        ),
                        if (route.totalClients != null)
                          Text(
                            '${route.completedClients ?? 0}/${route.totalClients} clientes',
                            style: const TextStyle(color: Color(0xFF666666)),
                          ),
                      ],
                    ),
                    trailing: _buildStatusBadge(route.status),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RouteDetailScreen(route: route),
                        ),
                      );
                      _loadData(); // Recargar por si actualizó información
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildScheduleTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Calendario próximamente',
            style: TextStyle(color: Colors.grey[600], fontSize: 18),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return const Color(0xFF37474F);
      case 'in_progress':
        return const Color(0xFFFF9800);
      case 'completed':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'scheduled':
        return Icons.schedule;
      case 'in_progress':
        return Icons.play_arrow;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'scheduled':
        color = const Color(0xFF37474F);
        text = 'Programada';
        break;
      case 'in_progress':
        color = const Color(0xFFFF9800);
        text = 'En Progreso';
        break;
      case 'completed':
        color = const Color(0xFF4CAF50);
        text = 'Completada';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
