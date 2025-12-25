import 'package:flutter/material.dart';
import '../../models/company_model.dart';
import '../../services/company_service.dart';
import 'create_company_screen.dart';

class CompanyDetailScreen extends StatefulWidget {
  final CompanyModel company;

  const CompanyDetailScreen({super.key, required this.company});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  final _companyService = CompanyService();
  Map<String, dynamic>? _stats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.company.name),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    ElevatedButton.icon(
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
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        _companyService.toggleCompanyStatus(
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
                  ],
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
}

