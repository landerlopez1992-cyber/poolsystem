import 'package:flutter/material.dart';
import 'admin_sidebar.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final int? selectedIndex;
  final ValueChanged<int>? onItemSelected;

  const AdminLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.floatingActionButton,
    this.selectedIndex,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          // Sidebar estático - siempre visible, NUNCA desaparece
          Material(
            child: AdminSidebar(
              selectedIndex: selectedIndex ?? _getSelectedIndexFromTitle(title),
              onItemSelected: onItemSelected ?? (index) {
                // Si ya estamos en la pantalla correcta, no hacer nada
                final currentIndex = selectedIndex ?? _getSelectedIndexFromTitle(title);
                if (currentIndex == index) return;
                
                // Navegar al dashboard y cambiar de sección
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/admin',
                  (route) => false,
                  arguments: index, // Pasar el índice como argumento
                );
              },
            ),
          ),
          // Contenido principal - usar ClipRect para evitar que se desborde
          Expanded(
            child: ClipRect(
              child: Column(
                children: [
                  // AppBar
                  AppBar(
                    title: Text(title),
                    backgroundColor: const Color(0xFF37474F),
                    foregroundColor: Colors.white,
                    leading: actions == null || actions!.isEmpty
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        : null,
                    actions: actions,
                  ),
                  // Contenido
                  Expanded(
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  int _getSelectedIndexFromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('dashboard')) return 0;
    if (lowerTitle.contains('cliente')) return 1;
    if (lowerTitle.contains('trabajador')) return 2;
    if (lowerTitle.contains('administrador')) return 3;
    return 0; // Default a dashboard
  }
}

