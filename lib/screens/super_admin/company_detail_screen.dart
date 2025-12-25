import 'package:flutter/material.dart';
import '../../models/company_model.dart';
import '../../models/user_model.dart';
import '../../models/worker_model.dart';
import '../../services/company_service.dart';
import '../../services/user_service.dart';
import '../../services/worker_service.dart';
import '../../widgets/super_admin_layout.dart';
import 'create_company_screen.dart';
import '../admin/create_admin_user_screen.dart';
import '../admin/create_worker_screen.dart';

class CompanyDetailScreen extends StatefulWidget {
  final CompanyModel company;

  const CompanyDetailScreen({super.key, required this.company});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  final _companyService = CompanyService();
  final _userService = UserService();
  final _workerService = WorkerService();
  
  Map<String, dynamic>? _stats;
  List<UserModel> _adminUsers = [];
  List<WorkerModel> _workers = [];
  List<UserModel> _workerUsers = []; // Usuarios asociados a workers para obtener avatares
  
  bool _isLoadingStats = true;
  bool _isLoadingEmployees = true;
  bool _isLoadingWorkers = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadEmployees();
    _loadWorkers();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _companyService.getCompanyStats(widget.company.id);
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

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoadingEmployees = true;
    });
    try {
      final employees = await _userService.getAdminUsersByCompany(widget.company.id);
      setState(() {
        _adminUsers = employees;
        _isLoadingEmployees = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEmployees = false;
      });
    }
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _isLoadingWorkers = true;
    });
    try {
      final workers = await _workerService.getWorkersByCompany(widget.company.id);
      
      // Cargar usuarios asociados a los workers para obtener avatares
      final workerUserIds = workers.map((w) => w.userId).toList();
      if (workerUserIds.isNotEmpty) {
        try {
          final workerUsers = await _userService.getUsersByCompany(widget.company.id);
          _workerUsers = workerUsers.where((u) => u.role == 'worker').toList();
        } catch (e) {
          // Error silencioso
        }
      }
      
      setState(() {
        _workers = workers;
        _isLoadingWorkers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWorkers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SuperAdminLayout(
      title: widget.company.name,
      selectedIndex: 1, // Empresas
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateCompanyScreen(company: widget.company),
              ),
            );
            if (result == true && mounted) {
              Navigator.of(context).pop(true);
            }
          },
          tooltip: 'Editar',
        ),
      ],
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            // Información de la empresa
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de la Empresa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Nombre', widget.company.name),
                    if (widget.company.description != null)
                      _buildInfoRow('Descripción', widget.company.description!),
                    if (widget.company.address != null)
                      _buildInfoRow('Dirección', widget.company.address!),
                    if (widget.company.phone != null)
                      _buildInfoRow('Teléfono', widget.company.phone!),
                    if (widget.company.email != null)
                      _buildInfoRow('Email', widget.company.email!),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Estado: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.company.isActive
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.company.isActive ? 'Activa' : 'Suspendida',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Estadísticas
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estadísticas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingStats)
                      const Center(child: CircularProgressIndicator())
                    else if (_stats != null)
                      Column(
                        children: [
                          _buildStatCard(
                            'Trabajadores',
                            _stats!['total_workers'].toString(),
                            Icons.people,
                            const Color(0xFF4CAF50),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            'Clientes',
                            _stats!['total_clients'].toString(),
                            Icons.pool,
                            const Color(0xFFFF9800),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            'Rutas',
                            _stats!['total_routes'].toString(),
                            Icons.route,
                            const Color(0xFF37474F),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Empleados (Administradores)
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Empleados (Administradores)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFFFF9800),
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CreateAdminUserScreen(
                                  companyId: widget.company.id,
                                ),
                              ),
                            );
                            if (result == true) {
                              _loadEmployees();
                              _loadStats(); // Actualizar estadísticas
                            }
                          },
                          tooltip: 'Crear Empleado',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingEmployees)
                      const Center(child: CircularProgressIndicator())
                    else if (_adminUsers.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No hay empleados registrados',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._adminUsers.map((user) => _buildEmployeeCard(user)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Técnicos de Piscinas (Workers)
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Técnicos de Piscinas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFFFF9800),
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CreateWorkerScreen(
                                  companyId: widget.company.id,
                                ),
                              ),
                            );
                            if (result == true) {
                              _loadWorkers();
                              _loadStats(); // Actualizar estadísticas
                            }
                          },
                          tooltip: 'Crear Técnico de Piscinas',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingWorkers)
                      const Center(child: CircularProgressIndicator())
                    else if (_workers.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.pool_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No hay técnicos de piscinas registrados',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._workers.map((worker) => _buildWorkerCard(worker)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Acciones
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Acciones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botón Enviar Push - NO estirado, ancho controlado
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar envío de push
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Funcionalidad de Push próximamente')),
                          );
                        },
                        icon: const Icon(Icons.notifications),
                        label: const Text('Enviar Notificación Push'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Botón Suspender/Activar - NO estirado, ancho controlado
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _companyService.toggleCompanyStatus(
                            widget.company.id,
                            !widget.company.isActive,
                          );
                          if (mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                        icon: Icon(widget.company.isActive
                            ? Icons.block
                            : Icons.check_circle),
                        label: Text(widget.company.isActive
                            ? 'Suspender Empresa'
                            : 'Activar Empresa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.company.isActive
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Botón Eliminar - NO estirado, ancho controlado
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showDeleteConfirmation(context),
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Eliminar Empresa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que deseas eliminar la empresa "${widget.company.name}"?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFDC2626).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta acción no se puede deshacer. La empresa será marcada como inactiva.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await _companyService.deleteCompany(widget.company.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empresa eliminada exitosamente'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar empresa: $e'),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF666666),
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF37474F),
          backgroundImage: user.avatarUrl != null
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null
              ? Text(
                  (user.fullName?.isNotEmpty ?? false)
                      ? user.fullName![0].toUpperCase()
                      : user.email[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        title: Text(
          user.fullName ?? user.email,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            if (user.phone != null && user.phone!.isNotEmpty)
              Text(user.phone!),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user.isActive
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : const Color(0xFFDC2626).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.isActive ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  fontSize: 12,
                  color: user.isActive
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFDC2626),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerCard(WorkerModel worker) {
    // Obtener avatar del usuario asociado si existe
    final workerUser = _workerUsers.firstWhere(
      (u) => u.id == worker.userId,
      orElse: () => UserModel(
        id: worker.userId,
        email: worker.email ?? '',
        role: 'worker',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4CAF50),
          backgroundImage: workerUser.avatarUrl != null && workerUser.avatarUrl!.isNotEmpty
              ? NetworkImage(workerUser.avatarUrl!)
              : null,
          child: workerUser.avatarUrl == null || workerUser.avatarUrl!.isEmpty
              ? const Icon(Icons.pool, color: Colors.white, size: 20)
              : null,
        ),
        title: Text(
          worker.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(worker.email ?? 'Sin email'),
            if (worker.phone != null && worker.phone!.isNotEmpty)
              Text(worker.phone!),
            if (worker.specialization != null && worker.specialization!.isNotEmpty)
              Text(
                'Especialización: ${worker.specialization}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: worker.status == 'active'
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : const Color(0xFFDC2626).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                worker.status == 'active' ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  fontSize: 12,
                  color: worker.status == 'active'
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFDC2626),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

