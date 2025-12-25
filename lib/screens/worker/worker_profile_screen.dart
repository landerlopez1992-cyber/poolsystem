import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/worker_model.dart';
import '../../services/worker_service.dart';
import '../../services/supabase_service.dart';

class WorkerProfileScreen extends StatefulWidget {
  final WorkerModel worker;

  const WorkerProfileScreen({super.key, required this.worker});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  final _workerService = WorkerService();
  final _supabase = SupabaseService.client;
  String? _photoUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    // Obtener foto del usuario
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final userData = await _supabase
            .from('users')
            .select('avatar_url')
            .eq('id', user.id)
            .single();
        setState(() {
          _photoUrl = userData['avatar_url'] as String?;
        });
      }
    } catch (e) {
      // Error silencioso
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploading = true;
      });

      // Subir imagen a Supabase Storage
      final file = File(pickedFile.path);
      final fileName = '${widget.worker.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'worker-profiles/$fileName';

      await _supabase.storage.from('avatars').upload(filePath, file);

      // Obtener URL pública
      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);

      // Actualizar en la base de datos
      await _workerService.updateWorkerProfilePhoto(
        workerId: widget.worker.id,
        photoUrl: publicUrl,
      );

      setState(() {
        _photoUrl = publicUrl;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada')),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Foto de perfil
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFF37474F),
                          backgroundImage: _photoUrl != null
                              ? NetworkImage(_photoUrl!)
                              : null,
                          child: _photoUrl == null
                              ? Text(
                                  widget.worker.fullName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        if (_isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickAndUploadImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Cambiar Foto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Información del trabajador
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Personal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Nombre', widget.worker.fullName),
                    if (widget.worker.email != null)
                      _buildInfoRow('Email', widget.worker.email!),
                    if (widget.worker.phone != null)
                      _buildInfoRow('Teléfono', widget.worker.phone!),
                    if (widget.worker.specialization != null)
                      _buildInfoRow(
                          'Especialización', widget.worker.specialization!),
                    if (widget.worker.licenseNumber != null)
                      _buildInfoRow(
                          'Licencia', widget.worker.licenseNumber!),
                    _buildInfoRow('Estado', _getStatusText(widget.worker.status)),
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

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Activo';
      case 'inactive':
        return 'Inactivo';
      case 'on_route':
        return 'En Ruta';
      default:
        return status;
    }
  }
}

