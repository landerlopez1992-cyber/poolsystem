class AppConfig {
  // Configuración de Supabase - Reemplazar con tus credenciales reales
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Roles del sistema
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleWorker = 'worker';
  
  // Estados de mantenimiento
  static const String maintenanceStatusPending = 'pending';
  static const String maintenanceStatusInProgress = 'in_progress';
  static const String maintenanceStatusCompleted = 'completed';
  static const String maintenanceStatusCancelled = 'cancelled';
  
  // Estados de ruta
  static const String routeStatusScheduled = 'scheduled';
  static const String routeStatusInProgress = 'in_progress';
  static const String routeStatusCompleted = 'completed';
  
  // Estados de trabajador
  static const String workerStatusActive = 'active';
  static const String workerStatusInactive = 'inactive';
  static const String workerStatusOnRoute = 'on_route';
  
  // Estados de cliente
  static const String clientStatusActive = 'active';
  static const String clientStatusInactive = 'inactive';
}

