# 📋 Instrucciones Simples - Pool System

## 🎯 ¿Qué está pasando?

Tienes **2 problemas**:

1. **El usuario no está en la base de datos** → Necesitas ejecutar un SQL
2. **La app móvil solo es para trabajadores** → Super Admin no puede entrar desde la app móvil

---

## ✅ SOLUCIÓN RÁPIDA

### Para crear el Super Admin (para la web):

1. **Abre Supabase**: https://supabase.com/dashboard/project/jbtsskgpratdijwelfls
2. **Ve a SQL Editor** (menú lateral izquierdo)
3. **Copia y pega esto**:

```sql
INSERT INTO users (id, email, full_name, role, is_active)
VALUES (
    'd430c58f-6373-4d13-9b10-47aaa4623946'::uuid,
    'landerlopez1992@gmail.com',
    'Super Admin',
    'super_admin',
    true
)
ON CONFLICT (id) DO UPDATE
SET 
    email = 'landerlopez1992@gmail.com',
    full_name = 'Super Admin',
    role = 'super_admin',
    is_active = true;
```

4. **Haz clic en "Run"** (o presiona Ctrl/Cmd + Enter)
5. **Listo** ✅

---

## 📱 Para Probar la App Móvil (Flutter)

La app móvil **SOLO funciona para trabajadores**. Necesitas crear un trabajador:

### Opción 1: Crear trabajador manualmente

1. **Crea un usuario en Authentication**:
   - Ve a Authentication > Users
   - Haz clic en "Add user"
   - Email: `trabajador@prueba.com`
   - Password: (la que quieras)
   - **Copia el ID** del usuario que se crea

2. **Crea una empresa primero** (si no existe):
   - Ve a Table Editor > companies
   - Crea una empresa manualmente
   - **Copia el ID** de la empresa

3. **Ejecuta este SQL** (reemplaza los IDs):

```sql
-- Insertar en users
INSERT INTO users (id, email, full_name, role, company_id, is_active)
VALUES (
    'ID_DEL_USUARIO_AUTH'::uuid,  -- Pega el ID del paso 1
    'trabajador@prueba.com',
    'Trabajador Prueba',
    'worker',
    'ID_DE_LA_EMPRESA'::uuid,  -- Pega el ID del paso 2
    true
);

-- Insertar en workers
INSERT INTO workers (company_id, user_id, full_name, status)
VALUES (
    'ID_DE_LA_EMPRESA'::uuid,  -- Pega el ID del paso 2
    'ID_DEL_USUARIO_AUTH'::uuid,  -- Pega el ID del paso 1
    'Trabajador Prueba',
    'active'
);
```

4. **Inicia sesión en la app móvil** con:
   - Email: `trabajador@prueba.com`
   - Password: (la que pusiste)

---

## 🌐 Arquitectura del Sistema

```
┌─────────────────────────────────────┐
│  APP MÓVIL (Flutter)               │
│  ✅ SOLO para TRABAJADORES         │
│  - Ver rutas                       │
│  - Completar trabajos              │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  WEB (Next.js) - Por crear          │
│  ✅ Para SUPER ADMIN y ADMIN        │
│  - Gestionar empresas              │
│  - Gestionar clientes              │
│  - Gestionar trabajadores          │
└─────────────────────────────────────┘
```

---

## ❓ Preguntas Frecuentes

### ¿Por qué no puedo entrar con Super Admin en la app móvil?
Porque la app móvil es **solo para trabajadores**. Super Admin debe usar la web (que aún no está creada).

### ¿Cómo pruebo la app móvil?
Necesitas crear un **trabajador** (ver instrucciones arriba).

### ¿Cuándo estará lista la web?
Cuando lo solicites, crearemos la aplicación web en Next.js para Super Admin y Admin.

---

## 🎯 Resumen

1. ✅ **Ejecuta el SQL** para crear Super Admin (para la web)
2. ✅ **Crea un trabajador** si quieres probar la app móvil
3. ⏳ **La web** se creará cuando lo solicites

---

¿Necesitas ayuda con algún paso específico?

