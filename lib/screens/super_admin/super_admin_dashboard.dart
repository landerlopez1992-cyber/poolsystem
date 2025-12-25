import 'package:flutter/material.dart';
import '../../models/company_model.dart';
import '../../services/company_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/super_admin_sidebar.dart';
import 'create_company_screen.dart';
import 'company_detail_screen.dart';
import 'support_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final _companyService = CompanyService();
  final _authService = AuthService();
  List<CompanyModel> _companies = [];
  bool _isLoading = true;
  bool _isLoadingStats = true;
  int _selectedIndex = 0; // 0: Dashboard, 1: Empresas, 2: Soporte
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    _loadStats();
  }

  Future<void> _loadCompanies() async {
    try {
      final companies = await _companyService.getAllCompanies();
      setState(() {
        _companies = companies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar empresas: $e')),
        );
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _companyService.getSuperAdminStats();
      setState(() {
        _stats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar estadísticas: $e')),
        );
      }
    }
  }

  Future<void> _toggleCompanyStatus(CompanyModel company) async {
    try {
      await _companyService.toggleCompanyStatus(company.id, !company.isActive);
      await _loadCompanies();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(company.isActive
                ? 'Empresa suspendida'
                : 'Empresa activada'),
          ),
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
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([_loadCompanies(), _loadStats()]);
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
                        'Empresas Activas',
                        _stats!['active_companies'].toString(),
                        Icons.business,
                        const Color(0xFF4CAF50),
                      ),
                      _buildStatCard(
                        'Empresas Inactivas',
                        _stats!['inactive_companies'].toString(),
                        Icons.business_outlined,
                        const Color(0xFFDC2626),
                      ),
                      _buildStatCard(
                        'Total Empleados',
                        _stats!['total_admins'].toString(),
                        Icons.people,
                        const Color(0xFF2196F3),
                      ),
                      _buildStatCard(
                        'Limpiadores de Pool',
                        _stats!['total_workers'].toString(),
                        Icons.pool,
                        const Color(0xFFFF9800),
                      ),
                      _buildStatCard(
                        'Suscripciones Activas',
                        '\$${_stats!['total_subscriptions'].toStringAsFixed(0)}',
                        Icons.payments,
                        const Color(0xFF9C27B0),
                        subtitle: '${_stats!['active_companies']} empresas × \$${_stats!['monthly_price'].toStringAsFixed(0)}/mes',
                      ),
                      _buildStatCard(
                        'Total Empresas',
                        _stats!['total_companies'].toString(),
                        Icons.domain,
                        const Color(0xFF37474F),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Lista de empresas
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  )
                else if (_companies.isEmpty)
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.business,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay empresas registradas',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Título de la sección
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Empresas Activas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                  // Lista de empresas
                  ..._companies.map((company) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        child: ListTile(
                          leading: company.logoUrl != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(company.logoUrl!),
                                  backgroundColor: Colors.grey[200],
                                )
                              : CircleAvatar(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  child: Text(
                                    company.name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  company.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C2C2C),
                                  ),
                                ),
                              ),
                              // Icono de suscripción
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: company.subscriptionType == 'lifetime'
                                      ? const Color(0xFF9C27B0).withOpacity(0.1)
                                      : const Color(0xFF2196F3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: company.subscriptionType == 'lifetime'
                                        ? const Color(0xFF9C27B0)
                                        : const Color(0xFF2196F3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      company.subscriptionType == 'lifetime'
                                          ? Icons.all_inclusive
                                          : Icons.calendar_month,
                                      size: 14,
                                      color: company.subscriptionType == 'lifetime'
                                          ? const Color(0xFF9C27B0)
                                          : const Color(0xFF2196F3),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      company.subscriptionPriceFormatted,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: company.subscriptionType == 'lifetime'
                                            ? const Color(0xFF9C27B0)
                                            : const Color(0xFF2196F3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            company.email ?? 'Sin email',
                            style: const TextStyle(
                              color: Color(0xFF666666),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                company.isActive
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: company.isActive
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Editar'),
                                      ],
                                    ),
                                    onTap: () async {
                                      await Future.delayed(
                                          const Duration(milliseconds: 100));
                                      if (mounted) {
                                        final result =
                                            await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                CreateCompanyScreen(
                                                    company: company),
                                          ),
                                        );
                                        if (result == true) {
                                          _loadCompanies();
                                          _loadStats();
                                        }
                                      }
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(
                                          company.isActive
                                              ? Icons.block
                                              : Icons.check_circle,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(company.isActive
                                            ? 'Suspender'
                                            : 'Activar'),
                                      ],
                                    ),
                                    onTap: () {
                                      _toggleCompanyStatus(company);
                                    },
                                  ),
                                  const PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility, size: 20),
                                        SizedBox(width: 8),
                                        Text('Ver Detalles'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    CompanyDetailScreen(company: company),
                              ),
                            );
                            // Recargar lista si se hizo alguna acción (eliminar, editar, etc.)
                            if (result == true) {
                              _loadCompanies();
                              _loadStats();
                            }
                          },
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompaniesContent() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadCompanies,
            child: _companies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay empresas registradas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _companies.length,
                    itemBuilder: (context, index) {
                      final company = _companies[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        child: ListTile(
                          leading: company.logoUrl != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(company.logoUrl!),
                                  backgroundColor: Colors.grey[200],
                                )
                              : CircleAvatar(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  child: Text(
                                    company.name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  company.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C2C2C),
                                  ),
                                ),
                              ),
                              // Icono de suscripción
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: company.subscriptionType == 'lifetime'
                                      ? const Color(0xFF9C27B0).withOpacity(0.1)
                                      : const Color(0xFF2196F3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: company.subscriptionType == 'lifetime'
                                        ? const Color(0xFF9C27B0)
                                        : const Color(0xFF2196F3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      company.subscriptionType == 'lifetime'
                                          ? Icons.all_inclusive
                                          : Icons.calendar_month,
                                      size: 14,
                                      color: company.subscriptionType == 'lifetime'
                                          ? const Color(0xFF9C27B0)
                                          : const Color(0xFF2196F3),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      company.subscriptionPriceFormatted,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: company.subscriptionType == 'lifetime'
                                            ? const Color(0xFF9C27B0)
                                            : const Color(0xFF2196F3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            company.email ?? 'Sin email',
                            style: const TextStyle(
                              color: Color(0xFF666666),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                company.isActive
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: company.isActive
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Editar'),
                                      ],
                                    ),
                                    onTap: () async {
                                      await Future.delayed(
                                          const Duration(milliseconds: 100));
                                      if (mounted) {
                                        final result =
                                            await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                CreateCompanyScreen(
                                                    company: company),
                                          ),
                                        );
                                        if (result == true) {
                                          _loadCompanies();
                                        }
                                      }
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(
                                          company.isActive
                                              ? Icons.block
                                              : Icons.check_circle,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(company.isActive
                                            ? 'Suspender'
                                            : 'Activar'),
                                      ],
                                    ),
                                    onTap: () {
                                      _toggleCompanyStatus(company);
                                    },
                                  ),
                                  const PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility, size: 20),
                                        SizedBox(width: 8),
                                        Text('Ver Detalles'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    CompanyDetailScreen(company: company),
                              ),
                            );
                            // Recargar lista si se hizo alguna acción (eliminar, editar, etc.)
                            if (result == true) {
                              _loadCompanies();
                            }
                          },
                        ),
                      );
                    },
                  ),
          );
  }

  Widget _buildCurrentContent() {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return _buildDashboardContent();
      case 1: // Empresas
        return _buildCompaniesContent();
      case 2: // Soporte
        return const SupportScreen();
      default:
        return _buildDashboardContent();
    }
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Empresas';
      case 2:
        return 'Soporte';
      default:
        return 'Panel Super Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          // Sidebar
          SuperAdminSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // AppBar
                AppBar(
                  title: Text(_getAppBarTitle()),
                  backgroundColor: const Color(0xFF37474F),
                  foregroundColor: Colors.white,
                  actions: [
                    if (_selectedIndex == 0 || _selectedIndex == 1)
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          _loadCompanies();
                          if (_selectedIndex == 0) {
                            _loadStats();
                          }
                        },
                        tooltip: 'Actualizar',
                      ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: _logout,
                      tooltip: 'Cerrar Sesión',
                    ),
                  ],
                ),
                // Contenido
                Expanded(
                  child: _buildCurrentContent(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateCompanyScreen(),
                  ),
                );
                if (result == true) {
                  _loadCompanies();
                }
              },
              backgroundColor: const Color(0xFFFF9800),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

