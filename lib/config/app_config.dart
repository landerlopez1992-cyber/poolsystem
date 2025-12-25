class AppConfig {
  // Configuración de Supabase
  static const String supabaseUrl = 'https://jbtsskgpratdijwelfls.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpidHNza2dwcmF0ZGlqd2VsZmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY2ODQ5NTAsImV4cCI6MjA4MjI2MDk1MH0.QNu6-ngYL3xdnDGa04jN6PRA4qb5utCZfSxYTC7P-yw';
  
  // Service Role Key (solo para uso en backend/edge functions, NUNCA en cliente)
  static const String supabaseServiceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpidHNza2dwcmF0ZGlqd2VsZmxzIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NjY4NDk1MCwiZXhwIjoyMDgyMjYwOTUwfQ.dEK99fqtNGpujw4G6IxBkofwI_IYSKd7ZB0_3Kljk8k';
  
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

