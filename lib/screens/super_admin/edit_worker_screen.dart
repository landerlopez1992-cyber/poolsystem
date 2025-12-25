import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../models/worker_model.dart';
import '../../models/user_model.dart';
import '../../services/worker_service.dart';
import '../../services/user_service.dart';
import '../../widgets/super_admin_layout.dart';
import '../../services/supabase_service.dart';
import '../../utils/storage_helper.dart';

class EditWorkerScreen extends StatefulWidget {
  final WorkerModel worker;
  final UserModel? workerUser; // Usuario asociado para obtener avatar

  const EditWorkerScreen({super.key, required this.worker, this.workerUser});

  @override
  State<EditWorkerScreen> createState() => _EditWorkerScreenState();
}

class _EditWorkerScreenState extends State<EditWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workerService = WorkerService();
  final _userService = UserService();
  final _supabase = SupabaseService.client;
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseController = TextEditingController();
  
  bool _isLoading = false;
  String _status = 'active';
  XFile? _selectedAvatarFile;
  Uint8List? _selectedAvatarBytes;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.worker.fullName;
    _phoneController.text = widget.worker.phone ?? '';
    _emailController.text = widget.worker.email ?? '';
    _specializationController.text = widget.worker.specialization ?? '';
    _licenseController.text = widget.worker.licenseNumber ?? '';
    _status = widget.worker.status;
    _avatarUrl = widget.workerUser?.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _specializationController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final fileBytes = await pickedFile.readAsBytes();

      if (!mounted) return;
      
      setState(() {
        _selectedAvatarFile = pickedFile;
        _selectedAvatarBytes = fileBytes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _saveWorker() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? finalAvatarUrl = _avatarUrl;

      // Si hay un avatar nuevo, subirlo primero
      if (_selectedAvatarFile != null && _selectedAvatarBytes != null) {
        try {
          final fileName = 'avatar_${widget.worker.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final filePath = 'avatars/$fileName';

          final publicUrl = await StorageHelper.uploadFile(
            supabase: _supabase,
            bucket: 'avatars',
            filePath: filePath,
            fileBytes: _selectedAvatarBytes!,
          );

          finalAvatarUrl = publicUrl;
          
          // Actualizar avatar en la tabla users (solo si hay avatar)
          if (finalAvatarUrl != null) {
            try {
              await _userService.updateUser(
                userId: widget.worker.userId,
                avatarUrl: finalAvatarUrl,
              );
            } catch (e) {
              // Si falla actualizar el avatar en users, continuar con la actualización del worker
              print('Advertencia: No se pudo actualizar avatar en users: $e');
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al subir avatar: $e')),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Actualizar worker
      await _workerService.updateWorker(
        workerId: widget.worker.id,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        specialization: _specializationController.text.trim().isEmpty
            ? null
            : _specializationController.text.trim(),
        licenseNumber: _licenseController.text.trim().isEmpty
            ? null
            : _licenseController.text.trim(),
        status: _status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Técnico actualizado exitosamente')),
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
          _isLoading = false;
        });
      }
    }
  }

  void _handleSidebarNavigation(int index) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/super-admin',
      (route) => false,
      arguments: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width > 600 ? 500.0 : double.infinity;
    
    return SuperAdminLayout(
      title: 'Editar Técnico de Piscinas',
      selectedIndex: 1, // Empresas
      onItemSelected: _handleSidebarNavigation,
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
                          // Selector de Avatar
                          Center(
                            child: GestureDetector(
                              onTap: _pickAvatar,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: _selectedAvatarBytes != null
                                        ? MemoryImage(_selectedAvatarBytes!)
                                        : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                            ? NetworkImage(_avatarUrl!)
                                            : null),
                                    child: _selectedAvatarBytes == null && (_avatarUrl == null || _avatarUrl!.isEmpty)
                                        ? const Icon(
                                            Icons.pool,
                                            size: 50,
                                            color: Colors.grey,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF9800),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Foto de Perfil',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Nombre
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre Completo *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El nombre es requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Email
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Teléfono
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Especialización
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _specializationController,
                              decoration: const InputDecoration(
                                labelText: 'Especialización',
                                border: OutlineInputBorder(),
                                hintText: 'Ej: Limpieza, Mantenimiento, Químico',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Número de Licencia
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _licenseController,
                              decoration: const InputDecoration(
                                labelText: 'Número de Licencia',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Estado
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButtonFormField<String>(
                              value: _status,
                              decoration: const InputDecoration(
                                labelText: 'Estado *',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'active',
                                  child: Text('Activo'),
                                ),
                                DropdownMenuItem(
                                  value: 'inactive',
                                  child: Text('Inactivo'),
                                ),
                                DropdownMenuItem(
                                  value: 'on_route',
                                  child: Text('En Ruta'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _status = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveWorker,
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
                              'Guardar Cambios',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

