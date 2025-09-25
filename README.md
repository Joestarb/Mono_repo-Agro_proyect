# 🌱 Agro Project - Monorepo

Un sistema de microservicios para gestión agrícola construido con NestJS, PostgreSQL y Docker.

## 📋 Tabla de Contenidos

- [Arquitectura](#-arquitectura)
- [Prerequisitos](#-prerequisitos)
- [Configuración Rápida](#-configuración-rápida)
- [Configuración Detallada](#-configuración-detallada)
- [Servicios](#-servicios)
- [Desarrollo](#-desarrollo)
- [Base de Datos](#-base-de-datos)
- [API Documentation](#-api-documentation)
- [Troubleshooting](#-troubleshooting)

## 🏗️ Arquitectura

El proyecto está estructurado como un monorepo con los siguientes servicios:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│     Gateway     │◄──►│  Auth Service   │◄──►│   PostgreSQL    │
│   (Port 3000)   │    │   (Port 3001)   │    │   (Port 5432)   │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

- **Gateway**: API Gateway que maneja el enrutamiento y autenticación
- **Auth Service**: Servicio de autenticación y gestión de usuarios
- **PostgreSQL**: Base de datos principal

## 🔧 Prerequisitos

Antes de comenzar, asegúrate de tener instalado:

- [Docker](https://docs.docker.com/get-docker/) (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+)
- [Node.js](https://nodejs.org/) (v18+)
- [PNPM](https://pnpm.io/installation) (v8+)

### Verificar instalación:

```bash
docker --version
docker-compose --version
node --version
pnpm --version
```

## 🚀 Configuración Rápida

### 1. Clonar y configurar el proyecto

```bash
git clone <tu-repositorio>
cd agro-project

# Instalar dependencias
pnpm install
```

### 2. Configurar variables de entorno

El proyecto incluye un archivo `.env` preconfigurado. Para producción, **debes cambiar** las credenciales:

```bash
cp .env .env.local  # Opcional: para configuración local personalizada
```

### 3. Usar el script de desarrollo

```bash
# Levantar todo el entorno
./dev.sh up

# Ver logs
./dev.sh logs

# Detener servicios
./dev.sh down
```

### 4. Verificar que todo funciona

Una vez levantados los servicios, verifica:

- **Gateway**: http://localhost:3000
- **Auth Service**: http://localhost:3001
- **PostgreSQL**: `localhost:5432`

## ⚙️ Configuración Detallada

### Variables de Entorno

El archivo `.env` contiene todas las configuraciones necesarias:

```bash
# Base de datos
POSTGRES_HOST=postgres          # Host de PostgreSQL (nombre del contenedor)
POSTGRES_PORT=5432             # Puerto interno de PostgreSQL
POSTGRES_USER=agro_user        # Usuario de la base de datos
POSTGRES_PASSWORD=agro_password # Contraseña (¡CAMBIAR EN PRODUCCIÓN!)
POSTGRES_DB=agro_db           # Nombre de la base de datos

# JWT
JWT_SECRET=your_super_secret_jwt_key_here_please_change_in_production
JWT_EXPIRATION=3600s

# Puertos externos (host)
GATEWAY_EXTERNAL_PORT=3000
AUTH_SERVICE_EXTERNAL_PORT=3001
POSTGRES_EXTERNAL_PORT=5432
```

### Comandos Docker Compose

Si prefieres usar Docker Compose directamente:

```bash
# Levantar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener servicios
docker-compose down

# Reconstruir imágenes
docker-compose build

# Resetear volúmenes
docker-compose down -v
```

## 🔧 Servicios

### Gateway (Puerto 3000)

El gateway actúa como punto de entrada único:

- **Tecnología**: NestJS
- **Puerto**: 3000
- **Características**:
  - Enrutamiento de requests
  - Validación de JWT
  - Proxy a microservicios

### Auth Service (Puerto 3001)

Servicio de autenticación y gestión de usuarios:

- **Tecnología**: NestJS + TypeORM
- **Puerto**: 3001
- **Base de datos**: PostgreSQL
- **Características**:
  - Registro de usuarios
  - Login/logout
  - Generación de JWT
  - Gestión de roles

### Base de Datos PostgreSQL

- **Puerto**: 5432
- **Base de datos**: `agro_db`
- **Usuario**: `agro_user`
- **Esquema**: Se crea automáticamente con TypeORM

## 💻 Desarrollo

### Script de Desarrollo

El proyecto incluye un script `dev.sh` que simplifica las tareas comunes:

```bash
./dev.sh help                 # Ver todos los comandos disponibles
./dev.sh up                   # Levantar servicios
./dev.sh down                 # Detener servicios
./dev.sh restart              # Reiniciar servicios
./dev.sh logs [servicio]      # Ver logs
./dev.sh db-reset             # Resetear base de datos
./dev.sh build                # Construir imágenes
./dev.sh install              # Instalar dependencias
```

### Estructura del Proyecto

```
agro-project/
├── apps/
│   ├── auth-service/         # Servicio de autenticación
│   │   ├── src/
│   │   │   ├── auth/         # Módulo de autenticación
│   │   │   ├── users/        # Entidad de usuarios
│   │   │   └── main.ts
│   │   ├── dockerfile
│   │   └── package.json
│   └── gateway/              # API Gateway
│       ├── src/
│       │   ├── auth/         # Estrategia JWT
│       │   ├── proxy/        # Controlador proxy
│       │   └── main.ts
│       ├── dockerfile
│       └── package.json
├── packages/
│   └── common/               # Código compartido
│       └── src/
│           └── dtos/
├── docker-compose.yml        # Configuración de contenedores
├── .env                      # Variables de entorno
├── dev.sh                   # Script de desarrollo
└── package.json             # Configuración monorepo
```

### Hot Reload

Los servicios están configurados con hot reload para desarrollo:

- Los cambios en `src/` se reflejan automáticamente
- No necesitas reiniciar los contenedores

### Agregar Nuevos Servicios

Para agregar un nuevo servicio:

1. Crear la carpeta en `apps/`
2. Configurar su `dockerfile`
3. Agregar el servicio a `docker-compose.yml`
4. Actualizar el script `dev.sh` si es necesario

## 🗄️ Base de Datos

### Conexión

La conexión a PostgreSQL está configurada en `auth-service/src/auth/auth.module.ts`:

```typescript
TypeOrmModule.forRoot({
  type: "postgres",
  host: process.env.POSTGRES_HOST,
  port: Number(process.env.POSTGRES_PORT),
  username: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
  entities: [__dirname + "/**/*.entity{.ts,.js}"],
  synchronize: true, // ¡Solo para desarrollo!
});
```

### Esquema

El esquema se crea automáticamente basado en las entidades TypeORM:

**Entidad User** (`apps/auth-service/src/users/users.entity.ts`):

```typescript
@Entity()
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;

  @Column({ default: "user" })
  role: string;
}
```

### Administrar la Base de Datos

```bash
# Conectarse a la base de datos
docker exec -it agro_postgres psql -U agro_user -d agro_db

# Resetear la base de datos
./dev.sh db-reset

# Hacer backup
docker exec agro_postgres pg_dump -U agro_user agro_db > backup.sql

# Restaurar backup
docker exec -i agro_postgres psql -U agro_user -d agro_db < backup.sql
```

## 📚 API Documentation

### Auth Service Endpoints

**POST** `/auth/register`

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**POST** `/auth/login`

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**GET** `/auth/profile` (requiere JWT)

```
Authorization: Bearer <jwt_token>
```

### Gateway Endpoints

El gateway redirige las requests:

- `/api/auth/*` → Auth Service
- Futuras rutas se agregarán aquí

## 🐛 Troubleshooting

### Problemas Comunes

**Error: "Port already in use"**

```bash
# Ver qué proceso usa el puerto
sudo netstat -tulpn | grep :3000

# Detener todos los contenedores
docker-compose down

# Limpiar puertos si es necesario
sudo fuser -k 3000/tcp
```

**Error: "Connection refused" a PostgreSQL**

```bash
# Verificar que PostgreSQL esté corriendo
docker-compose ps

# Ver logs de PostgreSQL
docker-compose logs postgres

# Esperar a que PostgreSQL esté listo
# El healthcheck debería manejarlo automáticamente
```

**Error: "Module not found"**

```bash
# Reinstalar dependencias
./dev.sh install

# O manualmente:
pnpm install
cd apps/auth-service && pnpm install
cd apps/gateway && pnpm install
```

**Problemas de permisos con Docker**

```bash
# En Linux, agregar usuario al grupo docker
sudo usermod -aG docker $USER

# Reiniciar sesión o usar:
newgrp docker
```

### Logs Útiles

```bash
# Ver logs de todos los servicios
./dev.sh logs

# Ver logs de un servicio específico
./dev.sh logs postgres
./dev.sh logs auth-service
./dev.sh logs gateway

# Seguir logs en tiempo real
docker-compose logs -f auth-service
```

### Limpiar el Entorno

```bash
# Detener y limpiar todo
docker-compose down -v --remove-orphans

# Limpiar imágenes no utilizadas
docker image prune -f

# Limpiar todo Docker (¡cuidado!)
docker system prune -a
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea tu feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la branch (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la licencia [UNLICENSED](LICENSE).

---

**¿Necesitas ayuda?** Revisa la sección [Troubleshooting](#-troubleshooting) o abre un issue en el repositorio.
