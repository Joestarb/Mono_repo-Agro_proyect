# GitHub Actions Workflows

## Auto Pull Request to main

Este workflow automatiza la creación de Pull Requests desde ramas de desarrollo hacia `main`.

### 🎯 Objetivo

Automatizar el proceso de integración continua verificando que el proyecto se construya correctamente antes de crear un PR automático hacia la rama principal.

### 🚀 Funcionamiento

#### Trigger

El workflow se ejecuta cuando:

- Se hace push a cualquier rama que coincida con el patrón `develop/**`
- Se ejecuta manualmente mediante `workflow_dispatch`

#### Jobs

##### 1. **Test Job** - Verificación de Build

Este job verifica que el proyecto se pueda construir correctamente:

**Pasos:**

1. **Checkout**: Clona el repositorio
2. **Set up PNPM**: Instala PNPM v8 para gestión de dependencias
3. **Set up Node.js**: Configura Node.js v20 con caché de PNPM
4. **Create .env file**:
   - Copia `local.example.env` a `.env`
   - Configura variables de entorno necesarias para el build:
     - `JWT_SECRET`: Clave de prueba para CI
     - `API_BASE_URL`: URL de la API
     - `POLL_INTERVAL_MS`: Intervalo de polling
     - `MONGODB_URI`: URI de conexión a MongoDB
     - `DB_NAME`: Nombre de la base de datos
5. **Make dev.sh executable**: Da permisos de ejecución al script de desarrollo
6. **Install dependencies**: Ejecuta `./dev.sh install` para instalar todas las dependencias
7. **Build Docker images**: Ejecuta `./dev.sh build` para construir las imágenes Docker
8. **Verify build success**: Verifica que las imágenes se hayan construido correctamente

##### 2. **Create PR Job** - Creación Automática de PR

Este job se ejecuta solo si el test job es exitoso:

**Funcionalidad:**

- Detecta la rama desde la que se ejecuta el workflow
- Compara la rama con `main` para verificar si hay commits nuevos
- Si hay commits adelante y no existe un PR abierto, crea uno automático
- El PR tiene el título: `Auto PR to main - [nombre-rama]`

### 📋 Requisitos

1. **Variables de entorno**: El archivo `local.example.env` debe existir en la raíz del proyecto
2. **Docker**: El runner debe tener Docker disponible (incluido en ubuntu-latest)
3. **Script dev.sh**: Debe estar en la raíz del proyecto con los comandos `install` y `build`

### 🔐 Permisos

El workflow requiere los siguientes permisos:

- `contents: write` - Para leer el código y crear commits
- `pull-requests: write` - Para crear Pull Requests

### 🔧 Configuración Local

Para probar el build localmente antes de hacer push:

```bash
# Copiar el archivo de ejemplo
cp local.example.env .env

# Editar las variables necesarias
nano .env

# Dar permisos al script
chmod +x ./dev.sh

# Instalar dependencias
./dev.sh install

# Construir las imágenes
./dev.sh build
```

### 📝 Notas

- El workflow usa `GITHUB_TOKEN` automático de GitHub Actions
- Si necesitas un token personalizado, crea un secret llamado `TOKEN_SECRET` en la configuración del repositorio
- El build se ejecuta en un runner de Ubuntu con Docker preinstalado
- Las imágenes construidas incluyen:
  - agro-repo-frontend
  - agro-repo-ingestion
  - gateway
  - auth-service
  - agro-repo-plots

### 🐛 Troubleshooting

#### El workflow falla en el paso de instalación

- Verifica que `package.json` exista en la raíz y en cada servicio
- Revisa que las dependencias sean compatibles con Node.js 20

#### El build de Docker falla

- Verifica que todos los Dockerfiles existan en las rutas correctas
- Revisa los logs del workflow para ver qué servicio falló
- Asegúrate de que las variables de entorno en `.env` sean correctas

#### No se crea el PR automático

- Verifica que la rama siga el patrón `develop/**`
- Confirma que haya commits nuevos respecto a `main`
- Revisa que no exista ya un PR abierto desde esa rama

### 🎨 Personalización

Para modificar el comportamiento del workflow:

1. **Cambiar la rama base**: Modifica `base: 'main'` en el script de creación de PR
2. **Agregar más tests**: Añade steps adicionales en el job `test`
3. **Modificar el patrón de ramas**: Cambia `develop/**` en la sección `on.push.branches`
4. **Personalizar el título del PR**: Edita la línea `title:` en el script de creación

### 📚 Referencias

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [PNPM Action](https://github.com/pnpm/action-setup)
- [GitHub Script Action](https://github.com/actions/github-script)
