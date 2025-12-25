# 📦 Crear Bucket de Avatares en Supabase Storage

## ⚠️ IMPORTANTE: El bucket `avatars` no existe

El error indica que el bucket `avatars` no está creado en Supabase Storage. Sigue estos pasos:

## 📋 Pasos para Crear el Bucket

### Opción 1: Desde la Interfaz de Supabase (Recomendado)

1. **Ir a Storage en Supabase:**
   - Abre tu proyecto en Supabase
   - Ve a la sección **Storage** en el menú lateral

2. **Crear Nuevo Bucket:**
   - Haz clic en **"New bucket"** o **"Crear bucket"**
   - Nombre del bucket: `avatars`
   - Marca la opción **"Public bucket"** (para que las imágenes sean accesibles públicamente)
   - Haz clic en **"Create bucket"**

3. **Configurar Políticas RLS:**
   - Una vez creado el bucket, ve a la pestaña **"Policies"**
   - Ejecuta el script SQL que está en `database/politicas_storage_rls.sql`
   - O crea las políticas manualmente desde la interfaz

### Opción 2: Desde SQL Editor

Ejecuta este script en el SQL Editor de Supabase:

```sql
-- Crear bucket 'avatars' si no existe
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;
```

Luego ejecuta las políticas RLS desde `database/politicas_storage_rls.sql`

## ✅ Verificación

Después de crear el bucket, verifica que:
- El bucket `avatars` aparece en la lista de buckets
- Está marcado como público
- Las políticas RLS están configuradas correctamente

## 🔒 Políticas RLS Necesarias

Las políticas RLS para el bucket `avatars` ya están en el archivo:
`database/politicas_storage_rls.sql`

Estas políticas permiten:
- Lectura pública de avatares
- Subida solo a usuarios autenticados
- Actualización/eliminación solo por el propietario

