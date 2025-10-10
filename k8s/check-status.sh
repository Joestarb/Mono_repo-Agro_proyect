#!/bin/bash

# Script para verificar el estado de todos los servicios en Kubernetes
# Muestra información detallada sobre pods, servicios y errores

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🔍 Estado de Servicios Agro - Kubernetes                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

# Función para verificar el estado de un pod
check_pod_status() {
    local app_label=$1
    local service_name=$2
    
    echo -e "\n${YELLOW}━━━ ${service_name} ━━━${NC}"
    
    # Obtener el pod
    POD_NAME=$(kubectl get pods -l app=${app_label} -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    if [ -z "$POD_NAME" ]; then
        echo -e "${RED}❌ No se encontró ningún pod${NC}"
        return
    fi
    
    # Obtener estado
    STATUS=$(kubectl get pod ${POD_NAME} -o jsonpath='{.status.phase}')
    READY=$(kubectl get pod ${POD_NAME} -o jsonpath='{.status.containerStatuses[0].ready}')
    RESTARTS=$(kubectl get pod ${POD_NAME} -o jsonpath='{.status.containerStatuses[0].restartCount}')
    
    echo -e "Pod: ${BLUE}${POD_NAME}${NC}"
    
    if [ "$STATUS" == "Running" ] && [ "$READY" == "true" ]; then
        echo -e "Estado: ${GREEN}✅ Running (Ready)${NC}"
    elif [ "$STATUS" == "Running" ]; then
        echo -e "Estado: ${YELLOW}⚠️  Running (Not Ready)${NC}"
    else
        echo -e "Estado: ${RED}❌ ${STATUS}${NC}"
    fi
    
    echo -e "Reinicios: ${RESTARTS}"
    
    # Verificar si hay errores
    STATE=$(kubectl get pod ${POD_NAME} -o jsonpath='{.status.containerStatuses[0].state}')
    if echo "$STATE" | grep -q "waiting"; then
        REASON=$(kubectl get pod ${POD_NAME} -o jsonpath='{.status.containerStatuses[0].state.waiting.reason}')
        MESSAGE=$(kubectl get pod ${POD_NAME} -o jsonpath='{.status.containerStatuses[0].state.waiting.message}')
        echo -e "${RED}Esperando: ${REASON}${NC}"
        [ ! -z "$MESSAGE" ] && echo -e "${RED}Mensaje: ${MESSAGE}${NC}"
    fi
    
    # Mostrar últimos logs si hay errores
    if [ "$STATUS" != "Running" ] || [ "$READY" != "true" ] || [ "$RESTARTS" -gt "0" ]; then
        echo -e "\n${YELLOW}📋 Últimos logs:${NC}"
        kubectl logs ${POD_NAME} --tail=5 2>/dev/null | sed 's/^/   /'
    fi
}

# Verificar bases de datos
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  📊 BASES DE DATOS                                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

check_pod_status "postgres" "PostgreSQL"
check_pod_status "mongo" "MongoDB"

# Verificar servicios backend
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🔧 SERVICIOS BACKEND                                         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

check_pod_status "auth-service" "Auth Service"
check_pod_status "ingestion-service" "Ingestion Service"
check_pod_status "plots-service" "Plots Service"
check_pod_status "gateway" "Gateway"

# Verificar frontend
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🌐 FRONTEND                                                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

check_pod_status "frontend" "Frontend"

# Resumen de servicios
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🌐 SERVICIOS EXPUESTOS                                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${YELLOW}NodePort Services:${NC}"
kubectl get services -o custom-columns=NAME:.metadata.name,TYPE:.spec.type,CLUSTER-IP:.spec.clusterIP,PORT:.spec.ports[0].port,NODEPORT:.spec.ports[0].nodePort | grep NodePort

# Obtener NODE-IP
echo -e "\n${YELLOW}🔗 URLs de acceso:${NC}"
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    NODE_IP=$(minikube ip)
    echo -e "   Frontend: ${GREEN}http://${NODE_IP}:30173${NC}"
    echo -e "   Gateway:  ${GREEN}http://${NODE_IP}:30001${NC}"
elif command -v kubectl &> /dev/null; then
    # Docker Desktop o localhost
    echo -e "   Frontend: ${GREEN}http://localhost:30173${NC}"
    echo -e "   Gateway:  ${GREEN}http://localhost:30001${NC}"
fi

# Eventos recientes
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  📢 EVENTOS RECIENTES                                         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

kubectl get events --sort-by='.lastTimestamp' --field-selector type!=Normal | tail -10

# Comandos útiles
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  📋 COMANDOS ÚTILES                                           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${YELLOW}Ver logs de un servicio específico:${NC}"
echo -e "   kubectl logs -f deployment/auth-service"
echo -e "   kubectl logs -f deployment/gateway"
echo -e "   kubectl logs -f deployment/postgres"

echo -e "\n${YELLOW}Reiniciar un deployment:${NC}"
echo -e "   kubectl rollout restart deployment/auth-service"

echo -e "\n${YELLOW}Ver descripción detallada de un pod:${NC}"
echo -e "   kubectl describe pod <pod-name>"

echo -e "\n${YELLOW}Ejecutar comando dentro de un pod:${NC}"
echo -e "   kubectl exec -it <pod-name> -- /bin/bash"

echo -e "\n${YELLOW}Volver a ejecutar este script:${NC}"
echo -e "   ./k8s/check-status.sh"

echo -e "\n${GREEN}════════════════════════════════════════════════════════════════${NC}"
