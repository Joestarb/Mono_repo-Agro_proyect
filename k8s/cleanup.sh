#!/bin/bash

# Script para eliminar todos los recursos de Kubernetes

set -e

echo "🗑️  Eliminando todos los recursos de Kubernetes..."
echo "=================================================="

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directorio de manifiestos
K8S_DIR="$(dirname "$0")"

# Confirmar antes de eliminar
read -p "⚠️  ¿Estás seguro de que quieres eliminar todos los recursos? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
    echo -e "${YELLOW}Operación cancelada${NC}"
    exit 0
fi

echo -e "\n${RED}Eliminando recursos...${NC}"

# Eliminar en orden inverso al despliegue
kubectl delete -f "${K8S_DIR}/services/frontend.yaml" --ignore-not-found=true
kubectl delete -f "${K8S_DIR}/services/gateway.yaml" --ignore-not-found=true
kubectl delete -f "${K8S_DIR}/services/plots-service.yaml" --ignore-not-found=true
kubectl delete -f "${K8S_DIR}/services/ingestion-service.yaml" --ignore-not-found=true
kubectl delete -f "${K8S_DIR}/services/auth-service.yaml" --ignore-not-found=true
kubectl delete -f "${K8S_DIR}/databases/mongo.yaml" --ignore-not-found=true
kubectl delete -f "${K8S_DIR}/databases/postgres.yaml" --ignore-not-found=true
kubectl delete -f "${K8S_DIR}/configs/secrets.yaml" --ignore-not-found=true
kubectl delete -f "${K8S_DIR}/configs/configmap.yaml" --ignore-not-found=true

echo -e "\n${GREEN}✅ Todos los recursos eliminados${NC}"

echo -e "\n${YELLOW}Estado actual:${NC}"
kubectl get all
