import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final AuthService _authService = AuthService();

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF37474F), // Color de fondo oscuro
      child: Column(
        children: [
          // Header del Sidebar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                const Icon(
                  Icons.pool, // Icono de piscina
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pool System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Administrador',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white30),
          // Opciones de navegación
          _buildListTile(
            context,
            0,
            'Dashboard',
            Icons.dashboard,
          ),
          _buildListTile(
            context,
            1,
            'Clientes',
            Icons.pool,
          ),
          _buildListTile(
            context,
            2,
            'Trabajadores',
            Icons.people,
          ),
          _buildListTile(
            context,
            3,
            'Administradores',
            Icons.admin_panel_settings,
          ),
          const Spacer(), // Empuja el logout al final
          // Botón de Cerrar Sesión
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                await _authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              },
              tileColor: Colors.red.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, int index, String title, IconData icon) {
    final isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? const Color(0xFFFF9800) : null, // Color naranja para seleccionado
      onTap: () => onItemSelected(index),
      selected: isSelected,
      selectedTileColor: const Color(0xFFFF9800),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      dense: true,
    );
  }
}

