#!/bin/bash

# Script para desplegar toda la aplicación en Kubernetes
# Aplica los manifiestos en el orden correcto

set -e

echo "🚀 Desplegando aplicación Agro en Kubernetes..."
echo "================================================"

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Directorio de manifiestos
K8S_DIR="$(dirname "$0")"

# Función para aplicar manifiestos
apply_manifest() {
    local manifest=$1
    local description=$2
    
    echo -e "\n${BLUE}📝 Aplicando: ${description}${NC}"
    kubectl apply -f "${manifest}"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ ${description} aplicado exitosamente${NC}"
    else
        echo -e "${RED}❌ Error al aplicar ${description}${NC}"
        exit 1
    fi
}

# Verificar que kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl no está instalado${NC}"
    exit 1
fi

# Verificar que el clúster está accesible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ No se puede conectar al clúster de Kubernetes${NC}"
    echo -e "${YELLOW}💡 Asegúrate de que tu clúster esté en ejecución${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Clúster de Kubernetes accesible${NC}"
echo ""

# 1. Aplicar ConfigMaps y Secrets primero
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}  PASO 1: Configuraciones y Secretos  ${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
apply_manifest "${K8S_DIR}/configs/configmap.yaml" "ConfigMap"
apply_manifest "${K8S_DIR}/configs/secrets.yaml" "Secrets"

# 2. Aplicar bases de datos
echo -e "\n${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}      PASO 2: Bases de Datos          ${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
apply_manifest "${K8S_DIR}/databases/postgres.yaml" "PostgreSQL"
apply_manifest "${K8S_DIR}/databases/mongo.yaml" "MongoDB"

echo -e "\n${BLUE}⏳ Esperando a que las bases de datos estén listas...${NC}"
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s || true
kubectl wait --for=condition=ready pod -l app=mongo --timeout=120s || true

# 3. Aplicar servicios backend
echo -e "\n${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}      PASO 3: Servicios Backend       ${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
apply_manifest "${K8S_DIR}/services/auth-service.yaml" "Auth Service"
apply_manifest "${K8S_DIR}/services/ingestion-service.yaml" "Ingestion Service"
apply_manifest "${K8S_DIR}/services/plots-service.yaml" "Plots Service"
apply_manifest "${K8S_DIR}/services/gateway.yaml" "Gateway"

echo -e "\n${BLUE}⏳ Esperando a que los servicios backend estén listos...${NC}"
echo -e "${BLUE}   Esto puede tardar varios minutos mientras se descargan las imágenes y se inician los contenedores...${NC}"

# Esperar a cada servicio individualmente
echo -e "\n${YELLOW}🔄 Esperando Auth Service...${NC}"
kubectl wait --for=condition=ready pod -l app=auth-service --timeout=180s 2>/dev/null || echo -e "${RED}⚠️  Auth Service no está listo (verifica logs)${NC}"

echo -e "${YELLOW}🔄 Esperando Ingestion Service...${NC}"
kubectl wait --for=condition=ready pod -l app=ingestion-service --timeout=180s 2>/dev/null || echo -e "${RED}⚠️  Ingestion Service no está listo (verifica logs)${NC}"

echo -e "${YELLOW}🔄 Esperando Plots Service...${NC}"
kubectl wait --for=condition=ready pod -l app=plots-service --timeout=180s 2>/dev/null || echo -e "${RED}⚠️  Plots Service no está listo (verifica logs)${NC}"

echo -e "${YELLOW}🔄 Esperando Gateway...${NC}"
kubectl wait --for=condition=ready pod -l app=gateway --timeout=180s 2>/dev/null || echo -e "${RED}⚠️  Gateway no está listo (verifica logs)${NC}"

# 4. Aplicar frontend
echo -e "\n${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}         PASO 4: Frontend             ${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
apply_manifest "${K8S_DIR}/services/frontend.yaml" "Frontend"

echo -e "\n${GREEN}=================================================="
echo -e "✅ Despliegue completado exitosamente"
echo -e "==================================================${NC}"

# Mostrar el estado de los pods
echo -e "\n${BLUE}📊 Estado de los pods:${NC}"
kubectl get pods

echo -e "\n${BLUE}🌐 Servicios expuestos:${NC}"
kubectl get services

echo -e "\n${YELLOW}📝 Acceso a la aplicación:${NC}"
echo -e "   Frontend: ${GREEN}http://<NODE-IP>:30173${NC}"
echo -e "   Gateway: ${GREEN}http://<NODE-IP>:30001${NC}"
echo ""
echo -e "${BLUE}💡 Para obtener la NODE-IP:${NC}"
echo -e "   Minikube: ${YELLOW}minikube ip${NC}"
echo -e "   Kind: ${YELLOW}kubectl get nodes -o wide${NC}"
echo -e "   Docker Desktop: ${YELLOW}localhost${NC}"
echo ""
echo -e "${BLUE}📋 Comandos útiles:${NC}"
echo -e "   Ver logs: ${YELLOW}kubectl logs -f <pod-name>${NC}"
echo -e "   Ver eventos: ${YELLOW}kubectl get events --sort-by=.metadata.creationTimestamp${NC}"
echo -e "   Ver todos los recursos: ${YELLOW}kubectl get all${NC}"
