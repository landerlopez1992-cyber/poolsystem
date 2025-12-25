import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/client_service.dart';
import '../../services/worker_service.dart';
import '../../services/user_service.dart';
import '../../models/client_model.dart';
import '../../models/worker_model.dart';
import '../../models/user_model.dart';
import 'create_client_screen.dart';
import 'create_worker_screen.dart';
import 'create_admin_user_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _authService = AuthService();
  final _clientService = ClientService();
  final _workerService = WorkerService();
  final _userService = UserService();
  
  String? _companyId;
  List<ClientModel> _clients = [];
  List<WorkerModel> _workers = [];
  List<UserModel> _adminUsers = [];
  
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
      setState(() {
        _companyId = user?.companyId;
      });

      if (_companyId != null) {
        await Future.wait([
          _loadClients(),
          _loadWorkers(),
          _loadAdminUsers(),
        ]);
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

  Future<void> _loadClients() async {
    if (_companyId == null) return;
    try {
      final clients = await _clientService.getClientsByCompany(_companyId!);
      setState(() {
        _clients = clients;
      });
    } catch (e) {
      // Error silencioso
    }
  }

  Future<void> _loadWorkers() async {
    if (_companyId == null) return;
    try {
      final workers = await _workerService.getWorkersByCompany(_companyId!);
      setState(() {
        _workers = workers;
      });
    } catch (e) {
      // Error silencioso
    }
  }

  Future<void> _loadAdminUsers() async {
    if (_companyId == null) return;
    try {
      final users = await _userService.getUsersByCompany(_companyId!);
      setState(() {
        _adminUsers = users.where((u) => u.isAdmin).toList();
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
          title: const Text('Panel Administrador'),
          backgroundColor: const Color(0xFF37474F),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Panel Administrador'),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildClientsTab(),
          _buildWorkersTab(),
          _buildAdminUsersTab(),
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
            icon: Icon(Icons.pool),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Trabajadores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Administradores',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildClientsTab() {
    return RefreshIndicator(
      onRefresh: _loadClients,
      child: _clients.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pool, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay clientes registrados',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
                      client.phone ?? client.email ?? 'Sin contacto',
                      style: const TextStyle(color: Color(0xFF666666)),
                    ),
                    trailing: client.status == 'active'
                        ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
                        : const Icon(Icons.cancel, color: Color(0xFFDC2626)),
                    onTap: () {
                      // TODO: Ver detalles del cliente
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildWorkersTab() {
    return RefreshIndicator(
      onRefresh: _loadWorkers,
      child: _workers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay trabajadores registrados',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _workers.length,
              itemBuilder: (context, index) {
                final worker = _workers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFF9800),
                      child: Text(
                        worker.fullName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      worker.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    subtitle: Text(
                      worker.specialization ?? 'Sin especialización',
                      style: const TextStyle(color: Color(0xFF666666)),
                    ),
                    trailing: Icon(
                      worker.status == 'active'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: worker.status == 'active'
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFDC2626),
                    ),
                    onTap: () {
                      // TODO: Ver detalles del trabajador
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAdminUsersTab() {
    return RefreshIndicator(
      onRefresh: _loadAdminUsers,
      child: _adminUsers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay administradores registrados',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _adminUsers.length,
              itemBuilder: (context, index) {
                final user = _adminUsers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF37474F),
                      child: Text(
                        (user.fullName ?? user.email)[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      user.fullName ?? user.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    subtitle: Text(
                      user.email,
                      style: const TextStyle(color: Color(0xFF666666)),
                    ),
                    trailing: user.isActive
                        ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
                        : const Icon(Icons.cancel, color: Color(0xFFDC2626)),
                  ),
                );
              },
            ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_companyId == null) return null;

    switch (_selectedIndex) {
      case 0: // Clientes
        return FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateClientScreen(companyId: _companyId!),
              ),
            );
            if (result == true) {
              _loadClients();
            }
          },
          backgroundColor: const Color(0xFFFF9800),
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 1: // Trabajadores
        return FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateWorkerScreen(companyId: _companyId!),
              ),
            );
            if (result == true) {
              _loadWorkers();
            }
          },
          backgroundColor: const Color(0xFFFF9800),
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 2: // Administradores
        return FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateAdminUserScreen(companyId: _companyId!),
              ),
            );
            if (result == true) {
              _loadAdminUsers();
            }
          },
          backgroundColor: const Color(0xFFFF9800),
          child: const Icon(Icons.add, color: Colors.white),
        );
      default:
        return null;
    }
  }
}
