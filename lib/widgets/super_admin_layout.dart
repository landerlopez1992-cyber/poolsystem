import 'package:flutter/material.dart';
import 'super_admin_sidebar.dart';

class SuperAdminLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final int? selectedIndex;

  const SuperAdminLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.floatingActionButton,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          // Sidebar estático - siempre visible, NUNCA desaparece
          SuperAdminSidebar(
            selectedIndex: selectedIndex ?? _getSelectedIndexFromTitle(title),
            onItemSelected: (index) {
              // Navegar según el índice
              switch (index) {
                case 0:
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/super-admin',
                    (route) => false,
                  );
                  break;
                case 1:
                  // Ya estamos en empresas
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/super-admin',
                    (route) => false,
                  );
                  // Luego cambiar a la vista de empresas
                  break;
                case 2:
                  // Navegar a soporte
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/super-admin',
                    (route) => false,
                  );
                  break;
              }
            },
          ),
          // Contenido principal
          Expanded(
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

