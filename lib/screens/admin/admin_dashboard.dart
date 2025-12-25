import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/client_service.dart';
import '../../services/worker_service.dart';
import '../../services/user_service.dart';
import '../../services/company_service.dart';
import '../../models/client_model.dart';
import '../../models/worker_model.dart';
import '../../models/user_model.dart';
import '../../widgets/admin_sidebar.dart';
import 'create_client_screen.dart';
import 'create_worker_screen.dart';
import 'create_admin_user_screen.dart';

class AdminDashboard extends StatefulWidget {
  final int? initialIndex; // Índice inicial para la sección
  
  const AdminDashboard({super.key, this.initialIndex});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _authService = AuthService();
  final _clientService = ClientService();
  final _workerService = WorkerService();
  final _userService = UserService();
  final _companyService = CompanyService();
  
  String? _companyId;
  List<ClientModel> _clients = [];
  List<WorkerModel> _workers = [];
  List<UserModel> _adminUsers = [];
  Map<String, dynamic>? _stats;
  
  late int _selectedIndex; // 0: Dashboard, 1: Clientes, 2: Trabajadores, 3: Administradores
  bool _isLoading = true;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    // Usar el índice inicial si se proporciona, sino default a 0 (Dashboard)
    _selectedIndex = widget.initialIndex ?? 0;
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
          _loadStats(),
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

  Future<void> _loadStats() async {
    if (_companyId == null) return;
    try {
      final stats = await _companyService.getCompanyStats(_companyId!);
      setState(() {
        _stats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
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

  void _handleSidebarNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Clientes';
      case 2:
        return 'Trabajadores';
      case 3:
        return 'Administradores';
      default:
        return 'Panel Administrador';
    }
  }

  Widget _buildCurrentContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildClientsContent();
      case 2:
        return _buildWorkersContent();
      case 3:
        return _buildAdminUsersContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          _loadClients(),
          _loadWorkers(),
          _loadAdminUsers(),
          _loadStats(),
        ]);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Estadísticas
                if (_isLoadingStats)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  )
                else if (_stats != null) ...[
                  // Grid de estadísticas
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        'Trabajadores',
                        _stats!['total_workers'].toString(),
                        Icons.people,
                        const Color(0xFF4CAF50),
                      ),
                      _buildStatCard(
                        'Clientes',
                        _stats!['total_clients'].toString(),
                        Icons.pool,
                        const Color(0xFFFF9800),
                      ),
                      _buildStatCard(
                        'Rutas',
                        _stats!['total_routes'].toString(),
                        Icons.route,
                        const Color(0xFF37474F),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                // Resumen rápido
                if (!_isLoading) ...[
                  _buildQuickSummary(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSummary() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        // Resumen de Clientes
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pool, color: const Color(0xFF4CAF50)),
                      const SizedBox(width: 8),
                      const Text(
                        'Clientes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total: ${_clients.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Activos: ${_clients.where((c) => c.status == 'active').length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Resumen de Trabajadores
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, color: const Color(0xFFFF9800)),
                      const SizedBox(width: 8),
                      const Text(
                        'Trabajadores',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total: ${_workers.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Activos: ${_workers.where((w) => w.status == 'active').length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Resumen de Administradores
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: const Color(0xFF37474F)),
                      const SizedBox(width: 8),
                      const Text(
                        'Administradores',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total: ${_adminUsers.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Activos: ${_adminUsers.where((u) => u.isActive).length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientsContent() {
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

  Widget _buildWorkersContent() {
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

  Widget _buildAdminUsersContent() {
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
      case 1: // Clientes
        return FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateClientScreen(companyId: _companyId!),
              ),
            );
            if (result == true) {
              _loadClients();
              _loadStats();
            }
          },
          backgroundColor: const Color(0xFFFF9800),
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 2: // Trabajadores
        return FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateWorkerScreen(companyId: _companyId!),
              ),
            );
            if (result == true) {
              _loadWorkers();
              _loadStats();
            }
          },
          backgroundColor: const Color(0xFFFF9800),
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 3: // Administradores
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Row(
          children: [
            Material(
              child: AdminSidebar(
                selectedIndex: 0,
                onItemSelected: _handleSidebarNavigation,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  AppBar(
                    title: const Text('Dashboard'),
                    backgroundColor: const Color(0xFF37474F),
                    foregroundColor: Colors.white,
                  ),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          // Sidebar estático - siempre visible
          Material(
            child: AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _handleSidebarNavigation,
            ),
          ),
          // Contenido principal
          Expanded(
            child: ClipRect(
              child: Column(
                children: [
                  // AppBar
                  AppBar(
                    title: Text(_getAppBarTitle()),
                    backgroundColor: const Color(0xFF37474F),
                    foregroundColor: Colors.white,
                  ),
                  // Contenido
                  Expanded(
                    child: _buildCurrentContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
