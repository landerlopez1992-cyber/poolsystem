import 'package:flutter/material.dart';
import 'super_admin_sidebar.dart';

class SuperAdminLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final int? selectedIndex;
  final ValueChanged<int>? onItemSelected;

  const SuperAdminLayout({
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
          // Usar Material para asegurar que los toques funcionen correctamente
          Material(
            child: SuperAdminSidebar(
              selectedIndex: selectedIndex ?? _getSelectedIndexFromTitle(title),
              onItemSelected: onItemSelected ?? (index) {
                // Si ya estamos en la pantalla correcta, no hacer nada
                final currentIndex = selectedIndex ?? _getSelectedIndexFromTitle(title);
                if (currentIndex == index) return;
                
                // Navegar según el índice
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/super-admin',
                  (route) => false,
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
    if (lowerTitle.contains('empresa')) return 1;
    if (lowerTitle.contains('soporte')) return 2;
    return 1; // Default a empresas
  }
}

