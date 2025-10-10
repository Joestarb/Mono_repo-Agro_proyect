# Guía de Despliegue en Kubernetes

Esta carpeta contiene los manifiestos de Kubernetes para desplegar la aplicación Agro Project.

## 📋 Estructura

```
k8s/
├── configs/
│   ├── configmap.yaml      # Configuraciones no sensibles
│   └── secrets.yaml         # Credenciales sensibles
├── databases/
│   ├── postgres.yaml        # PostgreSQL deployment + service + PVC
│   └── mongo.yaml           # MongoDB deployment + service + PVC
├── services/
│   ├── auth-service.yaml    # Auth service deployment + service
│   ├── ingestion-service.yaml
│   ├── gateway.yaml
│   ├── plots-service.yaml
│   └── frontend.yaml
├── build-images.sh          # Script para construir imágenes Docker
├── deploy.sh                # Script para desplegar todo
└── cleanup.sh               # Script para limpiar recursos
```

## 🚀 Despliegue Rápido

### Opción 1: Usando el script automático (Recomendado)

```bash
# 1. Construir las imágenes Docker
cd k8s
chmod +x build-images.sh deploy.sh cleanup.sh
./build-images.sh

# 2. Desplegar en Kubernetes
./deploy.sh
```

### Opción 2: Manual paso a paso

```bash
# 1. Construir imágenes Docker
docker build -f apps/auth-service/dockerfile -t agro-auth-service:latest .
docker build -f apps/gateway/dockerfile -t agro-gateway:latest .
docker build -f apps/agro-repo-ingestion/Dockerfile -t agro-ingestion-service:latest .
docker build -f apps/agro-repo-plots/Dockerfile -t agro-plots-service:latest .
docker build -f apps/agro-repo-frontend/dockerfile -t agro-frontend:latest .

# 2. Aplicar configuraciones
kubectl apply -f k8s/configs/configmap.yaml
kubectl apply -f k8s/configs/secrets.yaml

# 3. Desplegar bases de datos
kubectl apply -f k8s/databases/postgres.yaml
kubectl apply -f k8s/databases/mongo.yaml

# 4. Esperar a que las bases de datos estén listas
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s
kubectl wait --for=condition=ready pod -l app=mongo --timeout=120s

# 5. Desplegar servicios backend
kubectl apply -f k8s/services/auth-service.yaml
kubectl apply -f k8s/services/ingestion-service.yaml
kubectl apply -f k8s/services/plots-service.yaml
kubectl apply -f k8s/services/gateway.yaml

# 6. Desplegar frontend
kubectl apply -f k8s/services/frontend.yaml
```

## 🔧 Configuración

### Secrets y ConfigMaps

Antes de desplegar, asegúrate de revisar y modificar:

1. **k8s/configs/secrets.yaml**: Contiene las credenciales (CAMBIAR EN PRODUCCIÓN)
2. **k8s/configs/configmap.yaml**: Contiene las configuraciones generales

### Diferencias con Docker Compose

| Aspecto        | Docker Compose     | Kubernetes                         |
| -------------- | ------------------ | ---------------------------------- |
| Networking     | Red `agro_network` | Services internos (DNS automático) |
| Persistencia   | Volúmenes Docker   | PersistentVolumeClaims             |
| Configuración  | `.env` files       | ConfigMaps y Secrets               |
| Acceso externo | Puertos mapeados   | NodePort/LoadBalancer              |
| Health checks  | `healthcheck`      | `livenessProbe` y `readinessProbe` |

## 🌐 Acceso a los Servicios

Después del despliegue, los servicios estarán disponibles en:

- **Frontend**: `http://<NODE-IP>:30173`
- **Gateway**: `http://<NODE-IP>:30001`

### Obtener la NODE-IP:

```bash
# Minikube
minikube ip

# Docker Desktop
# Usar: localhost

# Kind o clúster real
kubectl get nodes -o wide
```

## 📊 Monitoreo

```bash
# Ver estado de todos los pods
kubectl get pods

# Ver logs de un servicio específico
kubectl logs -f deployment/gateway

# Ver eventos del clúster
kubectl get events --sort-by=.metadata.creationTimestamp

# Ver todos los recursos
kubectl get all

# Describir un pod específico
kubectl describe pod <pod-name>
```

## 🔍 Troubleshooting

### Las imágenes no se encuentran

Si usas Minikube, asegúrate de construir las imágenes en el contexto de Docker de Minikube:

```bash
eval $(minikube docker-env)
./build-images.sh
```

### Los pods están en CrashLoopBackOff

```bash
# Ver los logs del pod problemático
kubectl logs <pod-name>

# Ver eventos relacionados
kubectl describe pod <pod-name>
```

### Las bases de datos no inician

```bash
# Verificar los PersistentVolumeClaims
kubectl get pvc

# Ver logs de la base de datos
kubectl logs deployment/postgres
kubectl logs deployment/mongo
```

### Los servicios no se pueden comunicar

```bash
# Verificar que los services estén creados
kubectl get services

# Probar conectividad desde un pod
kubectl exec -it <pod-name> -- /bin/sh
# Dentro del pod:
curl http://postgres:5432
```

## 🗑️ Limpieza

Para eliminar todos los recursos desplegados:

```bash
./cleanup.sh
```

O manualmente:

```bash
kubectl delete -f k8s/ --recursive
```

## 📝 Notas Importantes

1. **Persistencia de datos**: Los datos de PostgreSQL y MongoDB se guardan en PersistentVolumeClaims. Si eliminas estos recursos, perderás los datos.

2. **Secrets en producción**: El archivo `secrets.yaml` contiene credenciales de ejemplo. En producción, usa:

   ```bash
   kubectl create secret generic agro-secrets \
     --from-literal=POSTGRES_PASSWORD=secure_password \
     --from-literal=MONGO_PASSWORD=secure_password \
     --from-literal=JWT_SECRET=secure_jwt_secret
   ```

3. **Recursos**: Los límites de CPU y memoria están configurados de forma conservadora. Ajústalos según tus necesidades.

4. **Health checks**: Los health checks asumen que tus servicios tienen un endpoint `/health`. Si no es así, ajusta o elimina los `livenessProbe` y `readinessProbe`.

## 🔄 Actualizar la Aplicación

```bash
# 1. Reconstruir la imagen modificada
docker build -f apps/gateway/dockerfile -t agro-gateway:latest .

# 2. Reiniciar el deployment
kubectl rollout restart deployment/gateway

# 3. Ver el progreso
kubectl rollout status deployment/gateway
```

## 🆚 Comparación: Docker Compose vs Kubernetes

### ¿Cuándo usar cada uno?

**Docker Compose** (Recomendado para desarrollo local):

- ✅ Rápido de levantar: `docker compose up`
- ✅ Fácil de debuggear
- ✅ No requiere configuración adicional
- ✅ Ideal para desarrollo local

**Kubernetes** (Recomendado para producción/aprendizaje):

- ✅ Escalabilidad automática
- ✅ Auto-recuperación de fallos
- ✅ Actualizaciones sin downtime
- ✅ Mejor monitoreo y observabilidad
- ⚠️ Mayor complejidad
- ⚠️ Requiere más recursos

**Para tu tarea**: Si ya tienes Docker Compose funcionando, úsalo para desarrollo. Kubernetes es útil para demostrar conocimiento de orquestación y despliegue en producción.
