import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../widgets/admin_layout.dart';
import '../../services/supabase_service.dart';
import '../../utils/storage_helper.dart';

class EditAdminUserScreen extends StatefulWidget {
  final UserModel user;

  const EditAdminUserScreen({super.key, required this.user});

  @override
  State<EditAdminUserScreen> createState() => _EditAdminUserScreenState();
}

class _EditAdminUserScreenState extends State<EditAdminUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final _supabase = SupabaseService.client;
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _isActive = true;
  XFile? _selectedAvatarFile;
  Uint8List? _selectedAvatarBytes;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.fullName ?? '';
    _phoneController.text = widget.user.phone ?? '';
    _isActive = widget.user.isActive;
    _avatarUrl = widget.user.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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

  Future<void> _saveEmployee() async {
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
          final fileName = 'avatar_${widget.user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final filePath = 'avatars/$fileName';

          final publicUrl = await StorageHelper.uploadFile(
            supabase: _supabase,
            bucket: 'avatars',
            filePath: filePath,
            fileBytes: _selectedAvatarBytes!,
          );

          finalAvatarUrl = publicUrl;
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

      await _userService.updateUser(
        userId: widget.user.id,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        avatarUrl: finalAvatarUrl,
        isActive: _isActive,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empleado actualizado exitosamente')),
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
      '/admin',
      (route) => false,
      arguments: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width > 600 ? 500.0 : double.infinity;
    
    return AdminLayout(
      title: 'Editar Administrador',
      selectedIndex: 3, // Administradores
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
                                            Icons.person,
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
                          // Email (solo lectura)
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              initialValue: widget.user.email,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                enabled: false,
                              ),
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
                          // Estado Activo/Inactivo
                          SizedBox(
                            width: double.infinity,
                            child: SwitchListTile(
                              title: const Text('Estado'),
                              subtitle: Text(_isActive ? 'Activo' : 'Inactivo'),
                              value: _isActive,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                              activeColor: const Color(0xFF4CAF50),
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
                      onPressed: _isLoading ? null : _saveEmployee,
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

