#!/bin/bash

# Script para diagnosticar y arreglar problemas comunes de despliegue

set -e

echo "🔧 Diagnóstico y reparación rápida de Kubernetes"
echo "================================================"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Verificar tipo de clúster
echo -e "\n${BLUE}1️⃣  Detectando tipo de clúster...${NC}"
CONTEXT=$(kubectl config current-context)
echo -e "   Clúster: ${YELLOW}${CONTEXT}${NC}"

if [[ "$CONTEXT" == "docker-desktop" ]]; then
    echo -e "   ${GREEN}✅ Docker Desktop detectado${NC}"
    NODE_IP="localhost"
elif command -v minikube &> /dev/null && minikube status &> /dev/null; then
    echo -e "   ${GREEN}✅ Minikube detectado${NC}"
    NODE_IP=$(minikube ip)
else
    echo -e "   ${YELLOW}⚠️  Clúster desconocido${NC}"
    NODE_IP="<NODE-IP>"
fi

# 2. Verificar estado de pods
echo -e "\n${BLUE}2️⃣  Estado de los pods:${NC}"
kubectl get pods --no-headers | while read -r line; do
    POD_NAME=$(echo $line | awk '{print $1}')
    STATUS=$(echo $line | awk '{print $3}')
    
    if [[ "$STATUS" == "Running" ]]; then
        echo -e "   ${GREEN}✅ ${POD_NAME}${NC}"
    elif [[ "$STATUS" == "CrashLoopBackOff" ]] || [[ "$STATUS" == "Error" ]]; then
        echo -e "   ${RED}❌ ${POD_NAME} - ${STATUS}${NC}"
    else
        echo -e "   ${YELLOW}⚠️  ${POD_NAME} - ${STATUS}${NC}"
    fi
done

# 3. Verificar imágenes Docker
echo -e "\n${BLUE}3️⃣  Verificando imágenes Docker locales...${NC}"
REQUIRED_IMAGES=("agro-auth-service" "agro-gateway" "agro-ingestion-service" "agro-plots-service" "agro-frontend")
MISSING_IMAGES=()

for image in "${REQUIRED_IMAGES[@]}"; do
    if docker images --format "{{.Repository}}" | grep -q "^${image}$"; then
        echo -e "   ${GREEN}✅ ${image}:latest${NC}"
    else
        echo -e "   ${RED}❌ ${image}:latest (NO ENCONTRADA)${NC}"
        MISSING_IMAGES+=("$image")
    fi
done

# 4. Ofrecer construir imágenes faltantes
if [ ${#MISSING_IMAGES[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}⚠️  Faltan ${#MISSING_IMAGES[@]} imágenes Docker${NC}"
    echo -e "${BLUE}💡 Necesitas construir las imágenes antes de desplegar en Kubernetes${NC}"
    echo ""
    read -p "¿Quieres construir todas las imágenes ahora? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[SsYy]$ ]]; then
        echo -e "\n${BLUE}🔨 Construyendo imágenes...${NC}"
        cd "$(dirname "$0")/.."
        ./k8s/build-images.sh
        echo -e "\n${GREEN}✅ Imágenes construidas${NC}"
        echo -e "${YELLOW}💡 Ahora debes reiniciar los deployments:${NC}"
        echo -e "   kubectl rollout restart deployment/auth-service"
        echo -e "   kubectl rollout restart deployment/gateway"
        echo -e "   kubectl rollout restart deployment/ingestion-service"
        echo -e "   kubectl rollout restart deployment/plots-service"
        echo -e "   kubectl rollout restart deployment/frontend"
    fi
fi

# 5. Verificar servicios expuestos
echo -e "\n${BLUE}4️⃣  Servicios expuestos:${NC}"
kubectl get svc --no-headers | grep NodePort | while read -r line; do
    SVC_NAME=$(echo $line | awk '{print $1}')
    PORT=$(echo $line | awk '{print $5}' | cut -d':' -f2 | cut -d'/' -f1)
    echo -e "   ${GREEN}✅ ${SVC_NAME}: http://${NODE_IP}:${PORT}${NC}"
done

# 6. URLs de acceso
echo -e "\n${BLUE}5️⃣  URLs de acceso:${NC}"
echo -e "   ${GREEN}Frontend: http://${NODE_IP}:30173${NC}"
echo -e "   ${GREEN}Gateway:  http://${NODE_IP}:30001${NC}"

# 7. Verificar conectividad
echo -e "\n${BLUE}6️⃣  Probando conectividad...${NC}"

# Probar frontend
if curl -s -o /dev/null -w "%{http_code}" http://${NODE_IP}:30173 2>/dev/null | grep -q "200\|304\|301"; then
    echo -e "   ${GREEN}✅ Frontend accesible${NC}"
else
    echo -e "   ${RED}❌ Frontend no responde${NC}"
fi

# Probar gateway
if curl -s -o /dev/null -w "%{http_code}" http://${NODE_IP}:30001 2>/dev/null | grep -q "200\|304\|404"; then
    echo -e "   ${GREEN}✅ Gateway accesible${NC}"
else
    echo -e "   ${RED}❌ Gateway no responde${NC}"
fi

# 8. Comandos útiles
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  📋 COMANDOS ÚTILES                                           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${YELLOW}Ver logs de pods con problemas:${NC}"
kubectl get pods --no-headers | grep -E 'CrashLoopBackOff|Error' | awk '{print $1}' | while read pod; do
    echo -e "   kubectl logs ${pod} --tail=50"
done

echo -e "\n${YELLOW}Reiniciar deployments:${NC}"
echo -e "   kubectl rollout restart deployment --all"

echo -e "\n${YELLOW}Eliminar y recrear todo:${NC}"
echo -e "   ./k8s/cleanup.sh && ./k8s/deploy.sh"

echo -e "\n${YELLOW}Ver estado detallado:${NC}"
echo -e "   ./k8s/check-status.sh"

echo -e "\n${GREEN}════════════════════════════════════════════════════════════════${NC}"
