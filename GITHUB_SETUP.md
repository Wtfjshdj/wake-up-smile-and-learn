# Configuración de GitHub para Wake Up Smile and Learn

## Paso 1: Crear repositorio en GitHub

1. Ve a [GitHub.com](https://github.com) e inicia sesión
2. Haz clic en el botón verde "New" o "+" en la esquina superior derecha
3. Selecciona "New repository"
4. Configura el repositorio:
   - **Repository name**: `wake-up-smile-and-learn`
   - **Description**: `A children's app that helps kids wake up with a smile and learn`
   - **Visibility**: 
     - ✅ **Public** (recomendado para compartir con amigos)
     - ❌ **Private** (solo tú y colaboradores)
   - ❌ **NO marques** "Add a README file" (ya tienes uno)
   - ❌ **NO marques** "Add .gitignore" (ya tienes uno)
   - ❌ **NO marques** "Choose a license" (ya tienes uno)
5. Haz clic en "Create repository"

## Paso 2: Conectar repositorio local con GitHub

Una vez creado el repositorio, copia la URL que aparece. Será algo como:
`https://github.com/TU-USUARIO/wake-up-smile-and-learn.git`

Luego ejecuta estos comandos en tu terminal:

```bash
# Reemplaza TU-USUARIO con tu nombre de usuario de GitHub
git remote add origin https://github.com/TU-USUARIO/wake-up-smile-and-learn.git

# Subir el código a GitHub
git push -u origin main
```

## Paso 3: Verificar que todo funciona

```bash
# Verificar que el repositorio remoto está configurado
git remote -v

# Verificar el estado
git status
```

## Paso 4: Compartir con amigos

Una vez que tengas el repositorio en GitHub, tus amigos pueden usar estos comandos:

```bash
# Clonar el proyecto
git clone https://github.com/TU-USUARIO/wake-up-smile-and-learn.git

# Entrar al directorio
cd wake-up-smile-and-learn

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

## Comandos útiles para el futuro

```bash
# Ver cambios pendientes
git status

# Añadir cambios
git add .

# Hacer commit
git commit -m "Descripción de los cambios"

# Subir cambios a GitHub
git push

# Bajar cambios de GitHub
git pull
```

## Solución de problemas

### Si tienes problemas de autenticación:
1. Ve a GitHub.com → Settings → Developer settings → Personal access tokens
2. Genera un nuevo token
3. Usa el token como contraseña cuando Git te lo pida

### Si el repositorio ya existe:
```bash
# Eliminar repositorio remoto existente
git remote remove origin

# Añadir el nuevo
git remote add origin https://github.com/TU-USUARIO/wake-up-smile-and-learn.git
``` 