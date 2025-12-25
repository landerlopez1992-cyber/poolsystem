import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/super_admin/super_admin_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/worker/worker_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await SupabaseService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pool System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/super-admin': (context) => const SuperAdminDashboard(),
        '/admin': (context) => const AdminDashboard(),
        '/worker': (context) => const WorkerDashboard(),
      },
    );
  }
}
