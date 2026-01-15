# 🚀 INFRAESTRUCTURA LISTA - GUÍA DE USO

## ✅ CAMBIOS REALIZADOS

### 1. **Sesiones Bastion Automáticas**
   - ✅ Se crean automáticamente 2 sesiones SSH al hacer `terraform apply`
   - ✅ Una sesión para cada web server
   - ✅ Sesiones válidas por 3 horas

### 2. **Script de Inicialización Mejorado**
   - ✅ Deshabilita `firewalld` completamente (más confiable)
   - ✅ Configura `iptables` directamente
   - ✅ Garantiza que nginx esté accesible en puerto 80
   - ✅ Logging detallado en `/var/log/user-data.log`

### 3. **Outputs SSH Listos para Usar**
   - ✅ Comandos SSH pre-construidos en los outputs de Terraform
   - ✅ Solo copiar y pegar para conectarse
   - ✅ No más OCIDs manuales

---

## 🎯 COMANDOS PARA DESPLEGAR

### 1️⃣ Destruir Infraestructura Existente (si existe)

```powershell
cd C:\Users\practicante_dtic2\Documents\Work\terraform-proyects\oci-architect-associate-labs\Terraform-OCI\oci-lb-2vms-nginx\modules
terraform destroy -auto-approve
```

### 2️⃣ Aplicar Nueva Configuración

```powershell
terraform init -upgrade
terraform plan
terraform apply -auto-approve
```

**Tiempo estimado:** ~3-4 minutos

---

## 📋 OUTPUTS DISPONIBLES

Después de `terraform apply`, verás estos outputs:

### 🌐 Load Balancer
```powershell
terraform output load_balancer_url
```

### 🔐 Comandos SSH

**Para Web Server 1:**
```powershell
terraform output -raw web_server_1_ssh_command
```

**Para Web Server 2:**
```powershell
terraform output -raw web_server_2_ssh_command
```

### 📊 Información General
```powershell
terraform output access_instructions
```

---

## 🖥️ CONECTARSE A LOS SERVIDORES

### Opción 1: Copiar y Ejecutar (Recomendado)

**Web Server 1:**
```powershell
$command = terraform output -raw web_server_1_ssh_command
Invoke-Expression $command
```

**Web Server 2:**
```powershell
$command = terraform output -raw web_server_2_ssh_command
Invoke-Expression $command
```

### Opción 2: Bash en Git Bash / WSL

**Web Server 1:**
```bash
eval $(terraform output -raw web_server_1_ssh_command)
```

**Web Server 2:**
```bash
eval $(terraform output -raw web_server_2_ssh_command)
```

---

## 🔍 VERIFICAR SERVIDORES WEB

Una vez conectado vía SSH:

### Verificar Nginx
```bash
sudo systemctl status nginx
```

### Verificar Puerto 80
```bash
sudo netstat -tlnp | grep :80
# o
sudo ss -tlnp | grep :80
```

### Probar Localmente
```bash
curl http://localhost
```

### Ver Logs de Inicialización
```bash
sudo cat /var/log/user-data.log
```

### Verificar Firewall (debe estar deshabilitado)
```bash
sudo systemctl status firewalld
# Debe mostrar: inactive (dead)
```

---

## 🌐 PROBAR EL LOAD BALANCER

### Desde PowerShell (Windows)

**Probar 10 veces para ver Round Robin:**
```powershell
For ($i=1; $i -le 10; $i++) {
    $lb_url = terraform output -raw load_balancer_url
    $response = Invoke-WebRequest -Uri $lb_url -UseBasicParsing
    if ($response.Content -match 'server-number">#(\d+)') {
        Write-Host "Request $i : Web Server #$($matches[1])"
    }
}
```

### Desde Navegador

1. Obtener URL:
   ```powershell
   terraform output load_balancer_url
   ```

2. Abrir en navegador y refrescar varias veces

3. Deberías ver alternar entre:
   - 🚀 Web Server #1
   - 🚀 Web Server #2

---

## 🔥 SOLUCIÓN DE PROBLEMAS

### Si backends aparecen en "CRITICAL"

**Conectarse a cada servidor y ejecutar:**

```bash
# Verificar si nginx está corriendo
sudo systemctl status nginx

# Si nginx no está corriendo, iniciarlo
sudo systemctl start nginx
sudo systemctl enable nginx

# Verificar firewall (debe estar desactivado)
sudo systemctl status firewalld

# Si firewall está activo, deshabilitarlo
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# Alternativa: Abrir puerto 80 manualmente
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
```

### Ver Estado de Backends

```powershell
# Obtener Load Balancer ID
$lb_id = terraform output -raw load_balancer_id

# Ver backends
oci lb backend-set get --load-balancer-id $lb_id --backend-set-name backend-web-servers
```

### Recrear Sesiones Bastion (si expiran)

Las sesiones duran 3 horas. Para recrearlas:

```powershell
terraform apply -replace="module.bastion.oci_bastion_session.web_server_1" -replace="module.bastion.oci_bastion_session.web_server_2"
```

---

## 📝 RESUMEN DE ARCHIVOS MODIFICADOS

1. **bastion/bastion.tf** - Agregadas sesiones SSH automáticas
2. **bastion/variables.tf** - Agregadas variables para web servers
3. **bastion/outputs.tf** - Agregados outputs de sesiones
4. **main.tf** - Agregado data source de región, variables para bastion
5. **outputs.tf** - Agregados comandos SSH pre-construidos
6. **compute/scripts/web_server_init.sh** - Script de inicialización robusto

---

## ⏱️ TIMELINE COMPLETO

1. `terraform destroy` → **~2 minutos**
2. `terraform apply` → **~3-4 minutos**
3. Esperar user_data scripts → **automático (~2 min)**
4. Sesiones Bastion creadas → **automático**
5. **TOTAL: ~6-7 minutos desde cero hasta todo funcional**

---

## ✨ VENTAJAS DE ESTA CONFIGURACIÓN

✅ **Zero manual work** - Todo automático
✅ **Sesiones pre-creadas** - No necesitas OCI Console
✅ **Comandos SSH listos** - Solo copiar/pegar
✅ **Firewall configurado** - Sin problemas de conectividad
✅ **Nginx funcionando** - Backends healthy desde el inicio
✅ **Outputs informativos** - Toda la información que necesitas

---

## 🎉 ¡LISTO PARA USAR!

Ejecuta:

```powershell
terraform apply -auto-approve
```

Luego:

```powershell
terraform output access_instructions
```

Y sigue las instrucciones mostradas. 🚀
