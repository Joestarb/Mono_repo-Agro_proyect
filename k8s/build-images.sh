#!/bin/bash

# Script para construir las imágenes Docker localmente para Kubernetes
# Este script es necesario porque Kubernetes necesita las imágenes disponibles

set -e

echo "🔨 Construyendo imágenes Docker para Kubernetes..."
echo "=================================================="

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para construir imagen
build_image() {
    local service_name=$1
    local dockerfile_path=$2
    local image_name=$3
    
    echo -e "\n${BLUE}📦 Construyendo: ${image_name}${NC}"
    docker build -f "${dockerfile_path}" -t "${image_name}:latest" .
    echo -e "${GREEN}✅ ${image_name} construida exitosamente${NC}"
}

# Cambiar al directorio raíz del proyecto
cd "$(dirname "$0")/.."

# Construir todas las imágenes
build_image "Auth Service" "./apps/auth-service/dockerfile" "agro-auth-service"
build_image "Gateway" "./apps/gateway/dockerfile" "agro-gateway"
build_image "Ingestion Service" "./apps/agro-repo-ingestion/Dockerfile" "agro-ingestion-service"
build_image "Plots Service" "./apps/agro-repo-plots/Dockerfile" "agro-plots-service"
build_image "Frontend" "./apps/agro-repo-frontend/dockerfile" "agro-frontend"

echo -e "\n${GREEN}=================================================="
echo -e "✅ Todas las imágenes construidas exitosamente"
echo -e "==================================================${NC}"

echo -e "\n${YELLOW}📋 Imágenes disponibles:${NC}"
docker images | grep "agro-"

echo -e "\n${BLUE}💡 Tip: Si usas Minikube, ejecuta:${NC}"
echo -e "   ${YELLOW}eval \$(minikube docker-env)${NC}"
echo -e "   ${YELLOW}y vuelve a ejecutar este script${NC}"
