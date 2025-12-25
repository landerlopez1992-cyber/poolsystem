# 🚀 Instrucciones de Inicio - Pool System

## ✅ Lo que ya está creado

### 1. Estructura del Proyecto Flutter
- ✅ Proyecto Flutter configurado
- ✅ Estructura de carpetas profesional
- ✅ Dependencias instaladas

### 2. Modelos de Datos
- ✅ UserModel (usuarios con roles)
- ✅ CompanyModel (empresas)
- ✅ ClientModel (clientes)
- ✅ WorkerModel (trabajadores)
- ✅ RouteModel (rutas de trabajo)
- ✅ MaintenanceModel (mantenimientos)
- ✅ ScheduleModel (calendario)

### 3. Servicios
- ✅ SupabaseService (conexión a Supabase)
- ✅ AuthService (autenticación y roles)

### 4. Pantallas Base
- ✅ LoginScreen (autenticación)
- ✅ SuperAdminDashboard (panel super admin)
- ✅ AdminDashboard (panel admin - básico)
- ✅ WorkerDashboard (panel trabajador - básico)

### 5. Base de Datos
- ✅ Esquema SQL completo en `database/schema.sql`
- ✅ Tablas con relaciones
- ✅ Índices para rendimiento
- ✅ Políticas RLS (Row Level Security)
- ✅ Triggers para updated_at

## 🔧 Pasos para Comenzar

### Paso 1: Configurar Supabase

1. **Crear cuenta en Supabase**
   - Ve a https://supabase.com
   - Crea una cuenta gratuita
   - Crea un nuevo proyecto

2. **Configurar Base de Datos**
   - Ve a SQL Editor en tu proyecto Supabase
   - Copia todo el contenido de `database/schema.sql`
   - Pega y ejecuta el script SQL
   - Verifica que todas las tablas se crearon correctamente

3. **Obtener Credenciales**
   - Ve a Settings > API
   - Copia la "Project URL"
   - Copia la "anon public" key

4. **Configurar la App**
   - Abre `lib/config/app_config.dart`
   - Reemplaza `YOUR_SUPABASE_URL` con tu Project URL
   - Reemplaza `YOUR_SUPABASE_ANON_KEY` con tu anon key

```dart
static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
static const String supabaseAnonKey = 'tu-anon-key-aqui';
```

### Paso 2: Crear Usuario Super Admin

1. **Desde Supabase Dashboard**
   - Ve a Authentication > Users
   - Crea un nuevo usuario manualmente
   - O usa el SQL Editor para crear el usuario:

```sql
-- Crear usuario en auth.users (esto se hace automáticamente al registrarse)
-- Luego actualizar la tabla users:

INSERT INTO users (id, email, full_name, role, is_active)
VALUES (
  'uuid-del-usuario-auth',
  'tu-email@ejemplo.com',
  'Tu Nombre',
  'super_admin',
  true
);
```

2. **O desde la App** (cuando implementes registro)
   - Crear pantalla de registro para super admin
   - O crear endpoint especial

### Paso 3: Probar la App

```bash
# Asegúrate de estar en el directorio del proyecto
cd "/Users/cubcolexpress/Desktop/Proyectos/Pool System"

# Ejecutar la app
flutter run
```

### Paso 4: Crear Primera Empresa (Super Admin)

Una vez que inicies sesión como Super Admin:
1. Usa el botón "+" en el dashboard
2. Crea una empresa de prueba
3. Asigna un Admin a esa empresa

## 📱 Funcionalidades a Implementar

### Prioridad Alta (MVP)

#### Para Trabajadores:
- [ ] Ver rutas asignadas
- [ ] Ver detalles de ruta
- [ ] Marcar inicio/fin de ruta
- [ ] Ver mantenimientos pendientes
- [ ] Registrar mantenimiento completado
- [ ] Tomar y subir fotos
- [ ] Ver calendario de trabajo
- [ ] Actualizar ubicación GPS

#### Para Administradores:
- [ ] Gestión completa de clientes (CRUD)
- [ ] Gestión completa de trabajadores (CRUD)
- [ ] Crear y asignar rutas
- [ ] Ver rutas en mapa
- [ ] Programar mantenimientos
- [ ] Ver reportes básicos
- [ ] Dashboard con estadísticas

#### Para Super Admin:
- [ ] Crear/editar empresas
- [ ] Asignar administradores a empresas
- [ ] Ver estadísticas globales
- [ ] Gestión de usuarios

### Prioridad Media

- [ ] Notificaciones push
- [ ] Modo offline
- [ ] Firma digital de clientes
- [ ] Checklist de mantenimiento
- [ ] Reportes avanzados
- [ ] Exportar datos

### Prioridad Baja

- [ ] Integraciones con pagos
- [ ] Email marketing
- [ ] SMS notifications
- [ ] IA para optimización de rutas

## 🌐 Próximo Paso: Crear la Web

Cuando estés listo para la aplicación web:

1. **Revisa** `PROPUESTA_WEB.md` para detalles completos
2. **Crea** el proyecto Next.js
3. **Configura** Supabase en la web
4. **Implementa** las funcionalidades una por una

## 🐛 Solución de Problemas

### Error: "Supabase no ha sido inicializado"
- Asegúrate de que `SupabaseService.initialize()` se llama en `main()`
- Verifica que las credenciales en `app_config.dart` son correctas

### Error: "Target of URI doesn't exist"
- Ejecuta `flutter pub get` para instalar dependencias

### Error de autenticación
- Verifica que el usuario existe en Supabase Auth
- Verifica que el usuario tiene un registro en la tabla `users`
- Verifica que el rol está correctamente asignado

### Error de permisos (RLS)
- Revisa las políticas RLS en Supabase
- Asegúrate de que el usuario tiene el rol correcto
- Verifica que las políticas permiten las operaciones necesarias

## 📚 Recursos Útiles

- [Documentación de Supabase](https://supabase.com/docs)
- [Documentación de Flutter](https://flutter.dev/docs)
- [Supabase Flutter Package](https://pub.dev/packages/supabase_flutter)

## 🎯 Checklist de Inicio

- [ ] Supabase configurado
- [ ] Base de datos creada (schema.sql ejecutado)
- [ ] Credenciales actualizadas en app_config.dart
- [ ] Usuario Super Admin creado
- [ ] App ejecuta sin errores
- [ ] Login funciona
- [ ] Dashboard Super Admin se muestra

## 💡 Tips

1. **Empieza Simple**: Implementa una funcionalidad a la vez
2. **Prueba en Real**: Usa datos reales desde el inicio
3. **Documenta**: Anota cambios importantes
4. **Versiona**: Usa Git para control de versiones
5. **Itera**: Mejora basándote en feedback

---

¡Listo para comenzar! 🚀

Si tienes dudas o necesitas ayuda, revisa la documentación o los archivos de ejemplo.

