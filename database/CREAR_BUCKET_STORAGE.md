# Crear Buckets de Storage en Supabase

## Pasos para crear los buckets necesarios

### 1. Acceder a Supabase Dashboard

1. Ve a [https://supabase.com](https://supabase.com)
2. Inicia sesión en tu cuenta
3. Selecciona tu proyecto: `jbtsskgpratdijwelfls`

### 2. Crear Bucket "company-logos"

1. En el menú lateral, haz clic en **Storage**
2. Haz clic en el botón **"New bucket"** o **"Crear bucket"**
3. Configura el bucket:
   - **Nombre**: `company-logos`
   - **Público**: ✅ **SÍ** (marcar como público para que las imágenes sean accesibles)
   - **File size limit**: `5 MB` (o el tamaño que prefieras)
   - **Allowed MIME types**: `image/jpeg, image/png, image/jpg` (opcional, para restringir tipos)
4. Haz clic en **"Create bucket"**

### 3. Crear Bucket "avatars" (si no existe)

1. Repite el proceso anterior
2. Configura el bucket:
   - **Nombre**: `avatars`
   - **Público**: ✅ **SÍ**
   - **File size limit**: `5 MB`
   - **Allowed MIME types**: `image/jpeg, image/png, image/jpg`
3. Haz clic en **"Create bucket"**

### 4. Configurar Políticas RLS (Row Level Security)

Después de crear los buckets, necesitas configurar las políticas de seguridad:

#### Para "company-logos":

1. Ve a **Storage** → **Policies** → Selecciona el bucket `company-logos`
2. Crea una política de **SELECT** (lectura pública):
   ```sql
   -- Permitir lectura pública de logos
   CREATE POLICY "Public Access for company logos"
   ON storage.objects FOR SELECT
   USING (bucket_id = 'company-logos');
   ```

3. Crea una política de **INSERT** (solo usuarios autenticados):
   ```sql
   -- Permitir subida solo a usuarios autenticados
   CREATE POLICY "Authenticated users can upload company logos"
   ON storage.objects FOR INSERT
   WITH CHECK (
     bucket_id = 'company-logos' 
     AND auth.role() = 'authenticated'
   );
   ```

#### Para "avatars":

1. Repite el proceso para el bucket `avatars`
2. Crea políticas similares para lectura pública y subida autenticada

### 5. Verificar que los buckets existen

1. Ve a **Storage** → **Buckets**
2. Deberías ver ambos buckets listados:
   - `company-logos` (público)
   - `avatars` (público)

## Nota Importante

Si los buckets no se crean correctamente o tienes problemas con las políticas, puedes ejecutar estos comandos SQL en el **SQL Editor** de Supabase:

```sql
-- Crear bucket company-logos (si no existe)
INSERT INTO storage.buckets (id, name, public)
VALUES ('company-logos', 'company-logos', true)
ON CONFLICT (id) DO NOTHING;

-- Crear bucket avatars (si no existe)
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;
```

Después de ejecutar estos comandos, configura las políticas RLS desde la interfaz de Storage → Policies.

