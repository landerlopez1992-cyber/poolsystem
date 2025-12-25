# 🔐 Cómo Crear el Usuario Super Admin

## Método Recomendado (Más Fácil)

### Paso 1: Crear Usuario en Authentication

1. Ve a tu proyecto en Supabase: https://supabase.com/dashboard/project/jbtsskgpratdijwelfls
2. En el menú lateral, haz clic en **"Authentication"**
3. Ve a la pestaña **"Users"**
4. Haz clic en el botón **"Add user"** o **"Invite user"**
5. Completa el formulario:
   - **Email**: Tu email (ej: `landerlopez1992@gmail.com`)
   - **Password**: Una contraseña segura
   - **Auto Confirm User**: ✅ Marca esta casilla (importante)
6. Haz clic en **"Create user"**

### Paso 2: Obtener el ID del Usuario

1. Una vez creado el usuario, aparecerá en la lista
2. Haz clic en el usuario para ver sus detalles
3. **Copia el ID** que aparece (es un UUID, algo como: `550e8400-e29b-41d4-a716-446655440000`)

### Paso 3: Asignar Rol Super Admin

1. Ve a **SQL Editor** en Supabase
2. Ejecuta este script, **reemplazando** `AQUI_VA_EL_ID_DEL_USUARIO` con el ID que copiaste:

```sql
INSERT INTO users (id, email, full_name, role, is_active)
VALUES (
    'AQUI_VA_EL_ID_DEL_USUARIO'::uuid,  -- Pega aquí el ID que copiaste
    'tu-email@ejemplo.com',              -- Tu email
    'Super Admin',                        -- Tu nombre
    'super_admin',
    true
)
ON CONFLICT (id) DO UPDATE
SET role = 'super_admin', is_active = true;
```

### Paso 4: Verificar

Ejecuta este query para verificar que todo está correcto:

```sql
SELECT id, email, full_name, role, is_active, created_at
FROM users
WHERE role = 'super_admin';
```

Deberías ver tu usuario con `role = 'super_admin'` y `is_active = true`.

---

## Ejemplo Completo

Si tu email es `landerlopez1992@gmail.com` y tu ID de usuario es `550e8400-e29b-41d4-a716-446655440000`, el script sería:

```sql
INSERT INTO users (id, email, full_name, role, is_active)
VALUES (
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'landerlopez1992@gmail.com',
    'Super Admin',
    'super_admin',
    true
)
ON CONFLICT (id) DO UPDATE
SET role = 'super_admin', is_active = true;
```

---

## ⚠️ Importante

- El ID debe ser un **UUID válido** (formato: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)
- El email debe coincidir con el email del usuario en Authentication
- Asegúrate de que el usuario esté creado en Authentication antes de ejecutar el INSERT

---

## 🚀 Después de Crear el Super Admin

1. Abre la app Flutter
2. Inicia sesión con el email y contraseña que creaste
3. Deberías ver el dashboard de Super Admin

---

## ❓ Problemas Comunes

### Error: "invalid input syntax for type uuid"
- **Solución**: Asegúrate de que el ID que copiaste sea un UUID válido y esté entre comillas simples

### Error: "duplicate key value violates unique constraint"
- **Solución**: El usuario ya existe. Usa el script con `ON CONFLICT` que actualiza el rol

### Error: "insert or update on table users violates foreign key constraint"
- **Solución**: El usuario no existe en `auth.users`. Crea primero el usuario en Authentication

