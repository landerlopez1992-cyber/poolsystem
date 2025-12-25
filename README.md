# Pool System - Sistema de Gestión de Empresas de Piscinas

Sistema completo para la gestión de empresas de mantenimiento y limpieza de piscinas.

## 🏗️ Arquitectura del Proyecto

### **App Móvil (Flutter/Dart)**
- **iOS y Android**: Para trabajadores de campo
- Funcionalidades:
  - Control de rutas
  - Gestión de mantenimientos
  - Calendario de trabajo (Schedule)
  - Geolocalización en tiempo real
  - Fotos y reportes

### **Web (Next.js - Propuesta)**
- **Panel Web**: Para administradores de empresas
- Funcionalidades:
  - Gestión de clientes
  - Gestión de trabajadores
  - Asignación de rutas
  - Reportes y estadísticas
  - Dashboard administrativo

### **Backend (Supabase)**
- Base de datos PostgreSQL
- Autenticación y autorización
- Row Level Security (RLS)
- API REST automática

## 👥 Roles del Sistema

1. **Super Admin** (Tú)
   - Administra todas las empresas
   - Crea y gestiona empresas
   - Ve estadísticas globales

2. **Admin** (Empresas)
   - Administra su propia empresa
   - Gestiona clientes y trabajadores
   - Asigna rutas y mantenimientos
   - Ve reportes de su empresa

3. **Worker** (Trabajadores)
   - Ve sus rutas asignadas
   - Registra mantenimientos
   - Actualiza estado de trabajo
   - Ve su calendario

## 📁 Estructura del Proyecto

```
Pool System/
├── lib/
│   ├── config/          # Configuración de la app
│   ├── models/          # Modelos de datos
│   ├── services/        # Servicios (Supabase, Auth, etc.)
│   ├── screens/         # Pantallas de la app
│   │   ├── auth/       # Login, registro
│   │   ├── super_admin/# Panel super admin
│   │   ├── admin/      # Panel admin empresa
│   │   └── worker/     # Panel trabajador
│   ├── widgets/         # Widgets reutilizables
│   └── utils/           # Utilidades
├── database/
│   └── schema.sql       # Esquema de base de datos
└── README.md
```

## 🗄️ Base de Datos

### Tablas Principales:
- **companies**: Empresas de piscinas
- **users**: Usuarios del sistema (con roles)
- **workers**: Trabajadores
- **clients**: Clientes de las empresas
- **routes**: Rutas de trabajo
- **maintenances**: Mantenimientos realizados
- **schedules**: Calendario de trabajo

## 🚀 Configuración Inicial

### 1. Configurar Supabase

1. Crear cuenta en [Supabase](https://supabase.com)
2. Crear un nuevo proyecto
3. Ejecutar el script SQL en `database/schema.sql`
4. Obtener URL y Anon Key del proyecto
5. Actualizar `lib/config/app_config.dart`:

```dart
static const String supabaseUrl = 'TU_URL_DE_SUPABASE';
static const String supabaseAnonKey = 'TU_ANON_KEY';
```

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Ejecutar la App

```bash
flutter run
```

## 📱 Funcionalidades de la App Móvil

### Para Trabajadores:
- ✅ Login con autenticación
- ✅ Dashboard personalizado
- 🔄 Ver rutas asignadas
- 🔄 Registrar mantenimientos
- 🔄 Calendario de trabajo
- 🔄 Geolocalización
- 🔄 Fotos de trabajos
- 🔄 Reportes

### Para Super Admin:
- ✅ Dashboard de empresas
- ✅ Lista de empresas
- 🔄 Crear/editar empresas
- 🔄 Estadísticas globales

## 🌐 Propuesta para la Web

**Tecnología Recomendada: Next.js 14+ con TypeScript**

### Ventajas:
- ✅ Framework profesional y moderno
- ✅ Server-side rendering (SSR)
- ✅ Excelente para dashboards
- ✅ Integración fácil con Supabase
- ✅ TypeScript para type safety
- ✅ Componentes reutilizables

### Estructura Propuesta:
```
pool-system-web/
├── app/              # Next.js App Router
├── components/       # Componentes React
├── lib/             # Utilidades y servicios
├── types/           # TypeScript types
└── public/          # Assets estáticos
```

## 🎨 Colores del Sistema

Siguiendo las reglas de diseño Cubalink23:
- Header/AppBar: `#37474F`
- Verde Secciones: `#4CAF50`
- Botones Principales: `#FF9800`
- Cards/Fondos: `#FFFFFF`
- Texto Principal: `#2C2C2C`
- Texto Secundario: `#666666`
- Fondo General: `#F5F5F5`

## 📋 Próximos Pasos

1. ✅ Estructura base creada
2. ✅ Modelos de datos definidos
3. ✅ Esquema de base de datos
4. ✅ Pantallas básicas
5. 🔄 Completar funcionalidades de trabajador
6. 🔄 Implementar geolocalización
7. 🔄 Sistema de notificaciones
8. 🔄 Crear aplicación web (Next.js)

## 🔐 Seguridad

- Row Level Security (RLS) en Supabase
- Autenticación con Supabase Auth
- Políticas de acceso por rol
- Validación de datos en cliente y servidor

## 📝 Notas

- Todo funciona con entornos reales (no demo)
- Backend exclusivamente en Supabase
- Sin datos de prueba ni simulaciones
