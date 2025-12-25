# 🏗️ Arquitectura del Sistema Pool System

## 📱 App Móvil (Flutter/Dart)

### Lenguaje: **Dart**
### Framework: **Flutter**

**Servicios en Dart:**
- `supabase_service.dart` - Conexión a Supabase
- `auth_service.dart` - Autenticación
- `company_service.dart` - Gestión de empresas
- `client_service.dart` - Gestión de clientes
- `worker_service.dart` - Gestión de trabajadores
- `user_service.dart` - Gestión de usuarios admin
- `route_service.dart` - Gestión de rutas

**Estos servicios SOLO se usan en la app móvil Flutter (iOS/Android)**

---

## 🌐 Web (Next.js/TypeScript)

### Lenguaje: **TypeScript**
### Framework: **Next.js 14+**

**Servicios en TypeScript (a crear):**
- `lib/supabase/client.ts` - Cliente de Supabase
- `lib/services/auth.ts` - Autenticación
- `lib/services/companies.ts` - Gestión de empresas
- `lib/services/clients.ts` - Gestión de clientes
- `lib/services/workers.ts` - Gestión de trabajadores
- `lib/services/routes.ts` - Gestión de rutas

**Estos servicios SOLO se usan en la aplicación web**

---

## 🔄 Conexión a la Base de Datos

```
┌─────────────────┐         ┌──────────────┐
│  App Flutter    │────────▶│              │
│  (Dart)         │         │   Supabase   │
└─────────────────┘         │  (PostgreSQL)│
                            │              │
┌─────────────────┐         │              │
│  Web Next.js    │────────▶│              │
│  (TypeScript)   │         └──────────────┘
└─────────────────┘
```

**Ambas aplicaciones se conectan DIRECTAMENTE a Supabase:**
- La app móvil usa `supabase_flutter` (paquete Dart)
- La web usa `@supabase/supabase-js` (paquete TypeScript/JavaScript)

**NO hay backend intermedio** - Cada aplicación se conecta directamente a Supabase.

---

## 📂 Estructura de Archivos

### App Móvil (Flutter)
```
lib/
├── services/          # Servicios en DART
│   ├── supabase_service.dart
│   ├── auth_service.dart
│   ├── company_service.dart
│   └── ...
├── models/            # Modelos en DART
├── screens/           # Pantallas Flutter
└── ...
```

### Web (Next.js)
```
pool-system-web/
├── lib/
│   ├── supabase/      # Cliente Supabase en TYPESCRIPT
│   │   └── client.ts
│   └── services/      # Servicios en TYPESCRIPT
│       ├── auth.ts
│       ├── companies.ts
│       └── ...
├── app/               # Next.js App Router
└── ...
```

---

## ✅ Resumen

1. **App Móvil**: Servicios en **Dart** → Se conecta a Supabase
2. **Web**: Servicios en **TypeScript** → Se conecta a Supabase
3. **Base de Datos**: **Supabase (PostgreSQL)** → Compartida por ambas
4. **NO hay duplicación**: Cada app tiene sus propios servicios en su lenguaje

---

## 🚀 Próximos Pasos

1. ✅ **App Móvil**: Continuar implementando funcionalidades en Dart
2. ⏳ **Web**: Crear proyecto Next.js con servicios en TypeScript (cuando estés listo)

Los servicios que estoy creando ahora en Dart son **SOLO para la app móvil**. Cuando creemos la web, haremos servicios similares pero en TypeScript.

