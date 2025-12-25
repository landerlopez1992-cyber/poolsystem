import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/company_service.dart';
import '../../models/company_model.dart';
import '../../widgets/super_admin_layout.dart';
import '../../services/supabase_service.dart';

class CreateCompanyScreen extends StatefulWidget {
  final CompanyModel? company; // Si se proporciona, es edición

  const CreateCompanyScreen({super.key, this.company});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyService = CompanyService();
  final _supabase = SupabaseService.client;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _selectedSubscriptionType = 'monthly';
  String? _logoUrl;
  File? _selectedLogoFile;
  bool _isUploadingLogo = false;

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _nameController.text = widget.company!.name;
      _descriptionController.text = widget.company!.description ?? '';
      _addressController.text = widget.company!.address ?? '';
      _phoneController.text = widget.company!.phone ?? '';
      _emailController.text = widget.company!.email ?? '';
      _selectedSubscriptionType = widget.company!.subscriptionType;
      _logoUrl = widget.company!.logoUrl;
    }
  }

  Future<void> _pickLogo() async {
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
        _selectedLogoFile = File(pickedFile.path);
        _isUploadingLogo = true;
      });

      // Si es edición, subir logo inmediatamente
      if (widget.company != null && _selectedLogoFile != null) {
        try {
          final fileName = 'logo_${widget.company!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final filePath = 'company-logos/$fileName';
          final fileBytes = await _selectedLogoFile!.readAsBytes();

          await _supabase.storage
              .from('company-logos')
              .upload(filePath, fileBytes);

          final publicUrl = _supabase.storage
              .from('company-logos')
              .getPublicUrl(filePath);

          setState(() {
            _logoUrl = publicUrl;
            _isUploadingLogo = false;
          });
        } catch (e) {
          setState(() {
            _isUploadingLogo = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al subir logo: $e')),
            );
          }
        }
      } else {
        setState(() {
          _isUploadingLogo = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUploadingLogo = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? finalLogoUrl = _logoUrl;
      final subscriptionPrice = _selectedSubscriptionType == 'monthly' ? 250.0 : 5000.0;

      if (widget.company == null) {
        // Si hay un archivo nuevo, subirlo primero
        if (_selectedLogoFile != null) {
          setState(() {
            _isUploadingLogo = true;
          });
          try {
            // Crear empresa primero para obtener el ID
            final tempCompany = await _companyService.createCompany(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              address: _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              email: _emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim(),
              logoUrl: null, // Se subirá después
              subscriptionType: _selectedSubscriptionType!,
              subscriptionPrice: subscriptionPrice,
            );

            // Subir logo
            final fileName = 'logo_${tempCompany.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final filePath = 'company-logos/$fileName';
            final fileBytes = await _selectedLogoFile!.readAsBytes();

            await _supabase.storage
                .from('company-logos')
                .upload(filePath, fileBytes);

            finalLogoUrl = _supabase.storage
                .from('company-logos')
                .getPublicUrl(filePath);

            // Actualizar empresa con logo
            await _companyService.updateCompany(
              companyId: tempCompany.id,
              logoUrl: finalLogoUrl,
            );

            // Crear usuario admin
            final adminEmail = _emailController.text.trim();
            if (adminEmail.isNotEmpty) {
              final authResponse = await _supabase.auth.signUp(
                email: adminEmail,
                password: _passwordController.text,
              );

              if (authResponse.user != null) {
                final userId = authResponse.user!.id;
                await _supabase.from('users').insert({
                  'id': userId,
                  'email': adminEmail,
                  'full_name': _nameController.text.trim(),
                  'role': 'admin',
                  'company_id': tempCompany.id,
                  'phone': _phoneController.text.trim().isEmpty
                      ? null
                      : _phoneController.text.trim(),
                  'is_active': true,
                });
              }
            }
          } catch (e) {
            setState(() {
              _isUploadingLogo = false;
            });
            throw Exception('Error al crear empresa: $e');
          }
        } else {
          // Crear nueva empresa con usuario admin sin logo
          await _companyService.createCompanyWithAdmin(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            address: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            adminEmail: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            adminPassword: _passwordController.text,
            logoUrl: finalLogoUrl,
            subscriptionType: _selectedSubscriptionType!,
            subscriptionPrice: subscriptionPrice,
          );
        }
        setState(() {
          _isUploadingLogo = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Empresa creada exitosamente')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        // Actualizar empresa existente
        // Si hay un archivo nuevo, subirlo primero
        if (_selectedLogoFile != null && finalLogoUrl == null) {
          setState(() {
            _isUploadingLogo = true;
          });
          try {
            final fileName = 'logo_${widget.company!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final filePath = 'company-logos/$fileName';
            final fileBytes = await _selectedLogoFile!.readAsBytes();

            await _supabase.storage
                .from('company-logos')
                .upload(filePath, fileBytes);

            finalLogoUrl = _supabase.storage
                .from('company-logos')
                .getPublicUrl(filePath);
          } catch (e) {
            setState(() {
              _isUploadingLogo = false;
            });
            throw Exception('Error al subir logo: $e');
          }
        }
        
        await _companyService.updateCompany(
          companyId: widget.company!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          logoUrl: finalLogoUrl,
          subscriptionType: _selectedSubscriptionType,
          subscriptionPrice: subscriptionPrice,
        );
        setState(() {
          _isUploadingLogo = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Empresa actualizada exitosamente')),
          );
          Navigator.of(context).pop(true);
        }
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

  @override
  Widget build(BuildContext context) {
    // Ancho máximo para el formulario (responsive)
    final maxWidth = MediaQuery.of(context).size.width > 600 ? 500.0 : double.infinity;
    
    return SuperAdminLayout(
      title: widget.company == null ? 'Crear Empresa' : 'Editar Empresa',
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Volver',
        ),
      ],
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
                          // Logo de la empresa
                          if (_logoUrl != null || _selectedLogoFile != null)
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _logoUrl != null
                                      ? NetworkImage(_logoUrl!)
                                      : (_selectedLogoFile != null
                                          ? FileImage(_selectedLogoFile!)
                                          : null) as ImageProvider?,
                                  child: _logoUrl == null && _selectedLogoFile == null
                                      ? const Icon(Icons.business, size: 50)
                                      : null,
                                ),
                                if (_isUploadingLogo)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          else
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              child: const Icon(Icons.business, size: 50),
                            ),
                          const SizedBox(height: 16),
                          // Botón para seleccionar logo
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isUploadingLogo ? null : _pickLogo,
                              icon: const Icon(Icons.image),
                              label: Text(_logoUrl != null || _selectedLogoFile != null
                                  ? 'Cambiar Logo'
                                  : 'Seleccionar Logo'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Nombre - NO estirado, ancho controlado
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre de la Empresa *',
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
                          // Descripción - NO estirado, ancho controlado
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Descripción',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Dirección - NO estirado, ancho controlado
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Dirección',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Teléfono - NO estirado, ancho controlado
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
                          // Email - NO estirado, ancho controlado
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                border: OutlineInputBorder(),
                                hintText: 'Email del administrador de la empresa',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              enabled: widget.company == null, // Solo editable al crear
                              validator: (value) {
                                if (widget.company == null) {
                                  if (value == null || value.isEmpty) {
                                    return 'El email es requerido';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Email inválido';
                                  }
                                } else if (value != null &&
                                    value.isNotEmpty &&
                                    !value.contains('@')) {
                                  return 'Email inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          // Solo mostrar campo de contraseña al crear nueva empresa
                          if (widget.company == null) ...[
                            const SizedBox(height: 16),
                            // Contraseña - NO estirado, ancho controlado
                            SizedBox(
                              width: double.infinity,
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña del Administrador *',
                                  border: const OutlineInputBorder(),
                                  hintText: 'Contraseña para el usuario admin',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (widget.company == null) {
                                    if (value == null || value.isEmpty) {
                                      return 'La contraseña es requerida';
                                    }
                                    if (value.length < 6) {
                                      return 'La contraseña debe tener al menos 6 caracteres';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          // Selector de Suscripción - NO estirado, ancho controlado
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButtonFormField<String>(
                              value: _selectedSubscriptionType,
                              decoration: const InputDecoration(
                                labelText: 'Tipo de Suscripción *',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'monthly',
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_month, size: 20),
                                      SizedBox(width: 8),
                                      Text('Mensual - \$250/mes'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'lifetime',
                                  child: Row(
                                    children: [
                                      Icon(Icons.all_inclusive, size: 20),
                                      SizedBox(width: 8),
                                      Text('Por Vida - \$5,000'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedSubscriptionType = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecciona un tipo de suscripción';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botón - NO estirado, ancho controlado
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCompany,
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
                          : Text(
                              widget.company == null ? 'Crear Empresa' : 'Guardar Cambios',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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

