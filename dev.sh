#!/bin/bash

# Script de desarrollo para el proyecto Agro
# Este script facilita el despliegue y gestión del entorno de desarrollo

set -e

echo "🌱 Agro Project - Script de Desarrollo"
echo "=================================="

# Función para mostrar ayuda
show_help() {
    echo "Uso: ./dev.sh [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  up        - Levantar todos los servicios"
    echo "  down      - Detener todos los servicios"
    echo "  restart   - Reiniciar todos los servicios"
    echo "  logs      - Ver logs de todos los servicios"
    echo "  db-reset  - Reiniciar la base de datos"
    echo "  build     - Construir las imágenes de Docker"
    echo "  install   - Instalar dependencias en todos los servicios"
    echo "  help      - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  ./dev.sh up"
    echo "  ./dev.sh logs auth-service"
    echo "  ./dev.sh db-reset"
}

# Función para verificar prerequisitos
check_prerequisites() {
    echo "🔍 Verificando prerequisitos..."
    
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker no está instalado"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo "❌ Docker Compose no está instalado"
        exit 1
    fi
    
    if ! command -v pnpm &> /dev/null; then
        echo "⚠️  PNPM no está instalado. Instalándolo..."
        npm install -g pnpm
    fi
    
    echo "✅ Prerequisitos verificados"
}

# Función para instalar dependencias
install_dependencies() {
    echo "📦 Instalando dependencias..."
    
    echo "  • Dependencias raíz..."
    pnpm install
    
    echo "  • Dependencias del auth-service..."
    cd apps/auth-service && pnpm install && cd ../..
    
    echo "  • Dependencias del gateway..."
    cd apps/gateway && pnpm install && cd ../..

    echo "  • Dependencias del Frontend..."
    cd apps/agro-repo-frontend && pnpm install && cd ../..

    echo "✅ Dependencias instaladas"
}

# Función para construir imágenes
build_images() {
    echo "🏗️  Construyendo imágenes de Docker..."
    docker-compose build
    echo "✅ Imágenes construidas"
}

# Función para levantar servicios
start_services() {
    echo "🚀 Levantando servicios..."
    docker-compose up -d
    echo "✅ Servicios iniciados"
    
    echo ""
    echo "📍 URLs disponibles:"
    echo "  • Gateway: http://localhost:3000"
    echo "  • PostgreSQL: localhost:5432"
    echo "  • Frontend: http://localhost:5001"
    echo ""
    echo "💡 Usa './dev.sh logs' para ver los logs"
}

# Función para detener servicios
stop_services() {
    echo "🛑 Deteniendo servicios..."
    docker-compose down
    echo "✅ Servicios detenidos"
}

# Función para reiniciar servicios
restart_services() {
    echo "🔄 Reiniciando servicios..."
    docker-compose down
    docker-compose up -d
    echo "✅ Servicios reiniciados"
}

# Función para mostrar logs
show_logs() {
    if [ -n "$2" ]; then
        echo "📋 Logs del servicio $2:"
        docker-compose logs -f "$2"
    else
        echo "📋 Logs de todos los servicios:"
        docker-compose logs -f
    fi
}

# Función para resetear la base de datos
reset_database() {
    echo "🗄️  Reseteando base de datos..."
    docker-compose down postgres
    docker volume rm agro-project_postgres_data || true
    docker-compose up -d postgres
    echo "✅ Base de datos reseteada"
}

# Función principal
main() {
    case "${1:-}" in
        "up")
            check_prerequisites
            start_services
            ;;
        "down")
            stop_services
            ;;
        "restart")
            restart_services
            ;;
        "logs")
            show_logs "$@"
            ;;
        "db-reset")
            reset_database
            ;;
        "build")
            check_prerequisites
            build_images
            ;;
        "install")
            check_prerequisites
            install_dependencies
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            echo "❌ Comando desconocido: ${1:-}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@"