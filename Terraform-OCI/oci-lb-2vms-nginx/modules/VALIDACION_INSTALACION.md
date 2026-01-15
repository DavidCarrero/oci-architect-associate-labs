# 🔍 VALIDACIÓN DE INSTALACIÓN DE SERVIDORES WEB

## 📋 ÍNDICE
1. [Validación de Cloud-Init](#validación-de-cloud-init)
2. [Verificar Plugin Bastion](#verificar-plugin-bastion)
3. [Verificar Instalación de Nginx](#verificar-instalación-de-nginx)
4. [Troubleshooting](#troubleshooting)

---

## 1️⃣ VALIDACIÓN DE CLOUD-INIT

### ¿Qué es cloud-init?
Cloud-init es el sistema que ejecuta automáticamente el script `user_data` cuando se crea la instancia. El script `web_server_init.sh` se inyecta en `metadata.user_data` de cada instancia.

### Verificar que se inyectó el script

**Ver outputs de Terraform:**
```bash
# Ver estado de las instancias
terraform output web_server_state

# Ver información de validación
terraform output web_server_init_validation

# Ver tiempo de creación
terraform output web_server_time_created
```

**Ver en Terraform state:**
```bash
# Ver metadata de la primera instancia
terraform state show 'module.compute.oci_core_instance.web_servers[0]' | grep -A 5 metadata

# Ver si el user_data está inyectado
terraform state show 'module.compute.oci_core_instance.web_servers[0]' | grep user_data
```

---

## 2️⃣ VERIFICAR PLUGIN BASTION

### ¿Por qué es importante?
Las sesiones de bastion **NO SE PUEDEN CREAR** hasta que el plugin Bastion esté en estado `RUNNING` en las instancias. Esto puede tomar **5-10 minutos** después de crear la instancia.

### Verificar en OCI Console

1. **Ir a la consola de OCI**
   - Navega a: `Compute` → `Instances`
   
2. **Seleccionar la instancia** (web-server-1 o web-server-2)

3. **Ir a "Oracle Cloud Agent"**
   - En el menú izquierdo, click en `Oracle Cloud Agent`
   
4. **Verificar estado del plugin "Bastion"**
   - Debe estar: ✅ `Enabled` y `Running`
   - Si está: ⚠️ `Enabled` pero `Stopped` → Esperar 5-10 minutos
   - Si no está habilitado → Terraform lo habilitó, pero toma tiempo

### Verificar con Terraform outputs

```bash
terraform output web_server_agent_bastion_status
```

**Resultado esperado:**
```json
[
  {
    "hostname" = "web-server-1"
    "id" = "ocid1.instance.oc1...."
    "bastion_plugin" = "Check in OCI Console: Instance Details → Oracle Cloud Agent → Bastion Plugin Status"
  },
  {
    "hostname" = "web-server-2"
    "id" = "ocid1.instance.oc1...."
    "bastion_plugin" = "Check in OCI Console: Instance Details → Oracle Cloud Agent → Bastion Plugin Status"
  }
]
```

### ⏱️ Timeline esperado

| Tiempo | Estado |
|--------|--------|
| 0 min | Instancia creada (PROVISIONING) |
| 1-2 min | Instancia RUNNING, cloud-init ejecutándose |
| 3-5 min | Nginx instalado y corriendo |
| 5-10 min | Plugin Bastion en estado RUNNING |
| 10+ min | Sesiones Bastion pueden crearse ✅ |

---

## 3️⃣ VERIFICAR INSTALACIÓN DE NGINX

### Opción A: Desde el Load Balancer (más fácil)

```bash
# Obtener IP del Load Balancer
terraform output load_balancer_url

# Probar desde tu navegador o curl
curl http://$(terraform output -raw load_balancer_public_ip)
```

**Resultado esperado:**
- Página HTML con información del servidor
- Al refrescar varias veces, verás Server #1 y Server #2 (Round Robin)

### Opción B: Conectarse vía SSH y verificar logs

**1. Esperar a que las sesiones bastion se creen:**
```bash
# Ver si las sesiones están listas
terraform output bastion_connection_instructions
```

**2. Conectarse al Web Server 1:**
```bash
# Ejecutar el comando SSH generado
terraform output -raw web_server_1_ssh_command | sh
```

**3. Una vez dentro de la instancia, verificar:**

```bash
# Ver logs de cloud-init (muestra TODO el proceso)
sudo cat /var/log/cloud-init-output.log

# Ver logs del script personalizado
sudo cat /var/log/user-data.log

# Verificar estado de nginx
sudo systemctl status nginx

# Ver si está escuchando en puerto 80
sudo netstat -tlnp | grep :80

# Probar HTTP localmente
curl http://localhost

# Ver contenido de la página web
cat /usr/share/nginx/html/index.html
```

**Salidas esperadas:**

✅ **Nginx corriendo:**
```
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since...
```

✅ **Puerto 80 escuchando:**
```
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      12345/nginx
```

✅ **HTTP funciona:**
```
HTTP/1.1 200 OK
Server: nginx/1.14.1
```

---

## 4️⃣ TROUBLESHOOTING

### ❌ Error: "Plugin Bastion must be RUNNING"

**Causa:** El plugin Bastion aún no está activo en la instancia.

**Solución:**
1. ✅ Esperar 5-10 minutos después de crear la instancia
2. ✅ Verificar en OCI Console que el plugin esté `Enabled` y `Running`
3. ✅ Ejecutar `terraform apply` nuevamente después de que el plugin esté RUNNING

### ❌ Load Balancer muestra backends en "CRITICAL"

**Causa:** Nginx no está respondiendo en puerto 80, o el firewall lo bloquea.

**Diagnóstico:**
1. Conectarse vía SSH a la instancia
2. Verificar nginx: `sudo systemctl status nginx`
3. Verificar firewall: `sudo firewall-cmd --list-all`
4. Ver logs: `sudo cat /var/log/user-data.log`

**Solución:**

```bash
# Si nginx no está corriendo
sudo systemctl start nginx
sudo systemctl enable nginx

# Si firewall bloquea puerto 80
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

# O deshabilitar firewall (solo para testing)
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

### ❌ Cloud-init no ejecutó el script

**Diagnóstico:**
```bash
# Ver estado de cloud-init
sudo cloud-init status

# Ver logs completos
sudo cat /var/log/cloud-init-output.log

# Ver si hay errores
sudo journalctl -u cloud-init
```

**Posibles causas:**
- Script tiene errores de sintaxis
- Falta el `#!/bin/bash` al inicio
- user_data mal codificado (debe ser base64)

**Solución:**
1. Verificar el script en: `modules/compute/scripts/web_server_init.sh`
2. Probar el script manualmente:
```bash
sudo bash /var/lib/cloud/instance/scripts/part-001
```

### ❌ No puedo conectarme vía SSH

**Diagnóstico:**
1. ✅ Verificar que la sesión bastion esté creada: `terraform state list | grep bastion_session`
2. ✅ Verificar que el plugin Bastion esté RUNNING (ver paso 2)
3. ✅ Verificar que la key SSH sea correcta

**Solución:**
```bash
# Recrear las sesiones (después de que el plugin esté RUNNING)
terraform destroy -target=module.bastion.oci_bastion_session.web_server_1
terraform destroy -target=module.bastion.oci_bastion_session.web_server_2
terraform apply
```

---

## 📊 CHECKLIST DE VALIDACIÓN

Usa este checklist para validar que todo está funcionando:

- [ ] **Instancias creadas y en estado RUNNING**
  ```bash
  terraform output web_server_state
  # Resultado esperado: ["RUNNING", "RUNNING"]
  ```

- [ ] **Plugin Bastion habilitado en instances.tf**
  ```bash
  grep -A 10 "agent_config" modules/compute/instances.tf
  # Debe mostrar: desired_state = "ENABLED"
  ```

- [ ] **Plugin Bastion en estado RUNNING en OCI Console**
  - Ver en: Compute → Instance → Oracle Cloud Agent → Bastion Plugin

- [ ] **Cloud-init ejecutó el script**
  ```bash
  # Dentro de la instancia vía SSH
  sudo cat /var/log/user-data.log | grep "Web Server configurado"
  ```

- [ ] **Nginx instalado y corriendo**
  ```bash
  # Dentro de la instancia vía SSH
  sudo systemctl is-active nginx
  # Resultado esperado: active
  ```

- [ ] **Puerto 80 escuchando**
  ```bash
  # Dentro de la instancia vía SSH
  sudo netstat -tlnp | grep :80
  ```

- [ ] **HTTP funciona localmente**
  ```bash
  # Dentro de la instancia vía SSH
  curl -I http://localhost
  # Resultado esperado: HTTP/1.1 200 OK
  ```

- [ ] **Load Balancer muestra backends en OK**
  - Ver en OCI Console: Networking → Load Balancers → Backend Sets

- [ ] **Aplicación web accesible desde internet**
  ```bash
  curl http://$(terraform output -raw load_balancer_public_ip)
  ```

- [ ] **Round Robin funciona**
  - Refrescar varias veces, debe mostrar Server #1 y Server #2 alternadamente

---

## 🎯 RESUMEN

### ✅ TODO CORRECTO SI:
1. Instancias en estado `RUNNING`
2. Plugin Bastion en estado `RUNNING` (toma 5-10 min)
3. Logs de cloud-init muestran: `✅ Web Server configurado`
4. Nginx activo: `systemctl is-active nginx` → `active`
5. Load Balancer backends en `OK`
6. Página web accesible desde el Load Balancer

### ⏱️ TIEMPOS ESPERADOS:
- Instancia RUNNING: 1-2 minutos
- Cloud-init completo: 3-5 minutos  
- Plugin Bastion RUNNING: 5-10 minutos
- Sesiones Bastion: Se crean después del plugin

### 🔧 SOLUCIÓN RÁPIDA:
```bash
# 1. Aplicar cambios
terraform apply

# 2. Esperar 10 minutos

# 3. Si falla por plugin Bastion, aplicar nuevamente
terraform apply

# 4. Verificar Load Balancer
curl http://$(terraform output -raw load_balancer_public_ip)

# 5. Conectarse vía SSH (si es necesario)
terraform output -raw web_server_1_ssh_command | sh
```

---

## 📚 ARCHIVOS RELEVANTES

| Archivo | Descripción |
|---------|-------------|
| `modules/compute/instances.tf` | Configuración de instancias y user_data |
| `modules/compute/scripts/web_server_init.sh` | Script de inicialización |
| `modules/bastion/bastion.tf` | Configuración de sesiones Bastion |
| `/var/log/cloud-init-output.log` | Log completo de cloud-init (en la instancia) |
| `/var/log/user-data.log` | Log del script personalizado (en la instancia) |

---

**Última actualización:** Enero 2026
