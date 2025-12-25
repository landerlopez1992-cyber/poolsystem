import 'package:flutter/material.dart';
import '../../models/company_model.dart';
import '../../services/company_service.dart';
import '../../services/auth_service.dart';
import 'create_company_screen.dart';
import 'company_detail_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCompanies();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Panel Super Admin'),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCompanies,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
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
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF4CAF50),
                              child: Text(
                                company.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              company.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C2C2C),
                              ),
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
                                    const PopupMenuItem(
                                      child: Row(
                                        children: [
                                          Icon(Icons.notifications, size: 20),
                                          SizedBox(width: 8),
                                          Text('Enviar Push'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CompanyDetailScreen(company: company),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}

