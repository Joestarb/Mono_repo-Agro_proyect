# 🎉 Aplicación Desplegada Exitosamente en Kubernetes

## ✅ Estado Actual

Todos los servicios están **corriendo correctamente** en tu clúster de Kubernetes (Docker Desktop).

### Pods en Ejecución:

- ✅ **PostgreSQL** - Base de datos relacional
- ✅ **MongoDB** - Base de datos NoSQL
- ✅ **Auth Service** - Servicio de autenticación
- ✅ **Gateway** - API Gateway principal
- ✅ **Ingestion Service** - Servicio de ingestión de datos
- ✅ **Plots Service** - Servicio de parcelas
- ✅ **Frontend** - Aplicación React

---

## 🌐 URLs de Acceso

### Frontend (Aplicación Web)

```
http://localhost:30173
```

**Descripción**: Interfaz de usuario principal de la aplicación

### Gateway API

```
http://localhost:30001
```

**Endpoints disponibles:**

- `POST http://localhost:30001/auth/register` - Registro de usuarios
- `POST http://localhost:30001/auth/login` - Login de usuarios
- `GET http://localhost:30001/plots` - Listar parcelas
- `POST http://localhost:30001/plots` - Crear parcela
- `GET http://localhost:30001/logs` - Ver logs del sistema

---

## 🧪 Probar la API

### 1. Registro de Usuario

```bash
curl -X POST http://localhost:30001/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test_user",
    "password": "Test1234!",
    "email": "test@example.com"
  }'
```

### 2. Login

```bash
curl -X POST http://localhost:30001/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test_user",
    "password": "Test1234!"
  }'
```

### 3. Listar Parcelas

```bash
curl http://localhost:30001/plots
```

---

## 📊 Comandos Útiles de Kubernetes

### Ver estado de todos los pods

```bash
kubectl get pods
```

### Ver logs de un servicio específico

```bash
kubectl logs -f deployment/gateway
kubectl logs -f deployment/auth-service
kubectl logs -f deployment/frontend
```

### Ver todos los servicios expuestos

```bash
kubectl get services
```

### Reiniciar un deployment

```bash
kubectl rollout restart deployment/gateway
kubectl rollout restart deployment/auth-service
```

### Ver estado detallado

```bash
./k8s/check-status.sh
```

### Diagnosticar problemas

```bash
./k8s/quick-fix.sh
```

---

## 🔄 Actualizar la Aplicación

Si haces cambios en el código:

```bash
# 1. Reconstruir las imágenes
./k8s/build-images.sh

# 2. Reiniciar los deployments
kubectl rollout restart deployment --all

# 3. Ver el progreso
kubectl get pods -w
```

---

## 🗑️ Limpiar Todo

Para eliminar todos los recursos de Kubernetes:

```bash
./k8s/cleanup.sh
```

Para volver a desplegar desde cero:

```bash
./k8s/cleanup.sh && ./k8s/deploy.sh
```

---

## 🐛 Solución de Problemas

### Los pods están en CrashLoopBackOff

1. Ver los logs: `kubectl logs <pod-name>`
2. Verificar las imágenes: `docker images | grep agro`
3. Reconstruir si es necesario: `./k8s/build-images.sh`

### No puedo acceder desde el navegador

1. Verificar que los pods estén Running: `kubectl get pods`
2. Verificar los servicios: `kubectl get services`
3. Usar `localhost` para Docker Desktop
4. Usar `minikube ip` si usas Minikube

### Servicios sin memoria

Si ves errores de "heap out of memory", los límites de memoria ya fueron aumentados a 1Gi.

---

## 📝 Diferencias vs Docker Compose

| Aspecto              | Docker Compose                   | Kubernetes                                   |
| -------------------- | -------------------------------- | -------------------------------------------- |
| Comando para iniciar | `docker compose up`              | `kubectl apply -f k8s/`                      |
| Ver logs             | `docker compose logs gateway`    | `kubectl logs deployment/gateway`            |
| Reiniciar            | `docker compose restart gateway` | `kubectl rollout restart deployment/gateway` |
| Detener              | `docker compose down`            | `kubectl delete -f k8s/`                     |
| Acceso               | Puertos directos (3000, 5173)    | NodePorts (30001, 30173)                     |

---

## 🎓 Conceptos Demostrados

Con este despliegue estás demostrando conocimiento de:

1. ✅ **Deployments** - Gestión de aplicaciones en Kubernetes
2. ✅ **Services** - Networking y descubrimiento de servicios
3. ✅ **ConfigMaps** - Gestión de configuración
4. ✅ **Secrets** - Gestión de credenciales sensibles
5. ✅ **PersistentVolumeClaims** - Persistencia de datos
6. ✅ **Resource Limits** - Control de memoria y CPU
7. ✅ **NodePort** - Exposición de servicios al exterior
8. ✅ **Multi-tier Architecture** - Aplicación de 3 capas completa

---

## ✨ Conclusión

Tu aplicación está **completamente funcional** en Kubernetes.

**Abre tu navegador y accede a:**
👉 **http://localhost:30173**

¡Disfruta de tu aplicación desplegada en Kubernetes! 🚀
