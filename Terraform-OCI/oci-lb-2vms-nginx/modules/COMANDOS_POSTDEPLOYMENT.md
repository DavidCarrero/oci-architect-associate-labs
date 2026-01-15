# COMANDOS POST-DEPLOYMENT - CONFIGURACIÓN MANUAL REQUERIDA

## ⚠️ PROBLEMA IDENTIFICADO
Los scripts `user_data` instalan nginx correctamente pero **no configuran el firewall automáticamente**.  
Esto causa que los backends aparezcan como "CRITICAL" en el Load Balancer.

## 📋 COMANDOS NECESARIOS DESPUÉS DEL DEPLOYMENT

### 1️⃣ CREAR SESIÓN DE BASTION PARA WEB-SERVER-1

```bash
oci bastion session create-managed-ssh \
  --bastion-id <BASTION_SERVICE_ID> \
  --target-resource-id <WEB_SERVER_1_INSTANCE_ID> \
  --target-os-username opc \
  --ssh-public-key-file ~/.ssh/id_rsa.pub \
  --session-ttl 10800 \
  --display-name "fix-webserver-1"
```

**Ejemplo con IDs reales del último deployment:**
```bash
oci bastion session create-managed-ssh \
  --bastion-id ocid1.bastion.oc1.sa-bogota-1.amaaaaaay7v6coqagyvdijodz6cpkuwkkx2yw7egzibgbkp2oh3rgtkkfdnq \
  --target-resource-id ocid1.instance.oc1.sa-bogota-1.anrgcljry7v6coqca25l6fmqiyhdoaphbdu7muu5yuu4nhngxzhmcqmxitma \
  --target-os-username opc \
  --ssh-public-key-file C:\Users\User\.ssh\id_rsa.pub \
  --session-ttl 10800 \
  --display-name "fix-webserver-1"
```

**Respuesta:** Copiar el `id` de la sesión (session_id)

---

### 2️⃣ CONECTAR VIA SSH Y CONFIGURAR FIREWALL EN WEB-SERVER-1

**Esperar 15 segundos** para que la sesión esté activa, luego ejecutar:

```bash
ssh -i ~/.ssh/id_rsa \
  -o StrictHostKeyChecking=no \
  -o ProxyCommand="ssh -i ~/.ssh/id_rsa -W %h:%p -p 22 <SESSION_ID>@host.bastion.sa-bogota-1.oci.oraclecloud.com" \
  opc@<WEB_SERVER_1_PRIVATE_IP> \
  'sudo firewall-cmd --permanent --add-service=http && sudo firewall-cmd --reload && sudo systemctl status nginx'
```

**Ejemplo con datos reales:**
```bash
ssh -i C:\Users\User\.ssh\id_rsa \
  -o StrictHostKeyChecking=no \
  -o ProxyCommand="ssh -i C:\Users\User\.ssh\id_rsa -W %h:%p -p 22 ocid1.bastionsession.oc1.sa-bogota-1.amaaaaaay7v6coqahx5nnkqwismpdnwfds6ipf45udgzsiiywtreuz4q3xla@host.bastion.sa-bogota-1.oci.oraclecloud.com" \
  opc@172.17.2.109 \
  'sudo firewall-cmd --permanent --add-service=http && sudo firewall-cmd --reload && sudo systemctl status nginx'
```

**Salida esperada:**
```
success
success
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running)
```

---

### 3️⃣ CREAR SESIÓN DE BASTION PARA WEB-SERVER-2

```bash
oci bastion session create-managed-ssh \
  --bastion-id <BASTION_SERVICE_ID> \
  --target-resource-id <WEB_SERVER_2_INSTANCE_ID> \
  --target-os-username opc \
  --ssh-public-key-file ~/.ssh/id_rsa.pub \
  --session-ttl 10800 \
  --display-name "fix-webserver-2"
```

**Ejemplo con IDs reales:**
```bash
oci bastion session create-managed-ssh \
  --bastion-id ocid1.bastion.oc1.sa-bogota-1.amaaaaaay7v6coqagyvdijodz6cpkuwkkx2yw7egzibgbkp2oh3rgtkkfdnq \
  --target-resource-id ocid1.instance.oc1.sa-bogota-1.anrgcljry7v6coqcav3et7vmwno7sffxjlrs6i2yotby5zi3gzv6igdbv7ga \
  --target-os-username opc \
  --ssh-public-key-file C:\Users\User\.ssh\id_rsa.pub \
  --session-ttl 10800 \
  --display-name "fix-webserver-2"
```

---

### 4️⃣ CONECTAR VIA SSH Y CONFIGURAR FIREWALL EN WEB-SERVER-2

**Esperar 15 segundos**, luego:

```bash
ssh -i ~/.ssh/id_rsa \
  -o StrictHostKeyChecking=no \
  -o ProxyCommand="ssh -i ~/.ssh/id_rsa -W %h:%p -p 22 <SESSION_ID>@host.bastion.sa-bogota-1.oci.oraclecloud.com" \
  opc@<WEB_SERVER_2_PRIVATE_IP> \
  'sudo firewall-cmd --permanent --add-service=http && sudo firewall-cmd --reload && sudo systemctl status nginx'
```

**Ejemplo con datos reales:**
```bash
ssh -i C:\Users\User\.ssh\id_rsa \
  -o StrictHostKeyChecking=no \
  -o ProxyCommand="ssh -i C:\Users\User\.ssh\id_rsa -W %h:%p -p 22 ocid1.bastionsession.oc1.sa-bogota-1.amaaaaaay7v6coqav4dvolyruevy3x36x2t5krjlikw25rdir3vib7kjefca@host.bastion.sa-bogota-1.oci.oraclecloud.com" \
  opc@172.17.2.24 \
  'sudo firewall-cmd --permanent --add-service=http && sudo firewall-cmd --reload && sudo systemctl status nginx'
```

---

### 5️⃣ VERIFICAR ESTADO DE LOS BACKENDS

**Esperar 30 segundos** para que el Load Balancer detecte los backends saludables:

```bash
# Web Server 1
oci lb backend-health get \
  --load-balancer-id <LOAD_BALANCER_ID> \
  --backend-set-name backend-web-servers \
  --backend-name <WEB_SERVER_1_IP>:80

# Web Server 2
oci lb backend-health get \
  --load-balancer-id <LOAD_BALANCER_ID> \
  --backend-set-name backend-web-servers \
  --backend-name <WEB_SERVER_2_IP>:80
```

**Ejemplo con datos reales:**
```bash
# Web Server 1
oci lb backend-health get \
  --load-balancer-id ocid1.loadbalancer.oc1.sa-bogota-1.aaaaaaaarnochghqiill74dawfux7axh2jbzbbdfywyc2bs4jehzlejperia \
  --backend-set-name backend-web-servers \
  --backend-name 172.17.2.109:80

# Web Server 2
oci lb backend-health get \
  --load-balancer-id ocid1.loadbalancer.oc1.sa-bogota-1.aaaaaaaarnochghqiill74dawfux7axh2jbzbbdfywyc2bs4jehzlejperia \
  --backend-set-name backend-web-servers \
  --backend-name 172.17.2.24:80
```

**Salida esperada:**
```json
{
  "data": {
    "health-check-results": [
      {
        "health-check-status": "OK",
        ...
      }
    ],
    "status": "OK"
  }
}
```

---

### 6️⃣ PROBAR EL LOAD BALANCER

```bash
# Probar 10 veces para verificar Round Robin
for i in {1..10}; do
  curl http://<LOAD_BALANCER_PUBLIC_IP>
done
```

**Ejemplo con IP real:**
```bash
# Linux/Mac
for i in {1..10}; do
  curl -s http://157.137.208.94 | grep -oP 'server-number">\K#?\d+'
done

# PowerShell
For ($i=1; $i -le 10; $i++) {
  $response = Invoke-WebRequest -Uri "http://157.137.208.94" -UseBasicParsing
  $response.Content -match 'server-number">[#]?(\d+)</div>'
  Write-Host "Request $i : Web Server #$($matches[1])"
}
```

---

## 📝 RESUMEN DE COMANDOS CRÍTICOS

### Solo comandos de firewall (si ya estás conectado vía SSH):
```bash
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

### Verificar nginx:
```bash
sudo systemctl status nginx
curl http://localhost
```

### Verificar firewall:
```bash
sudo firewall-cmd --list-services
```

---

## 🔧 COMANDOS RÁPIDOS PARA OBTENER IDs DEL TERRAFORM OUTPUT

Después de `terraform apply`, obtener los IDs necesarios:

```bash
# Bastion Service ID
terraform output bastion_service_id

# Web Server Instance IDs
terraform output web_server_ids

# Web Server Private IPs
terraform output web_server_1_private_ip
terraform output web_server_2_private_ip

# Load Balancer ID
terraform output load_balancer_id

# Load Balancer URL
terraform output load_balancer_url
```

---

## ⏱️ TIMELINE DE EJECUCIÓN

1. `terraform apply` → **~2 minutos**
2. Esperar user_data scripts → **3 minutos**
3. Crear sesión Bastion server 1 → **~15 segundos**
4. Conectar SSH y configurar firewall server 1 → **~5 segundos**
5. Crear sesión Bastion server 2 → **~15 segundos**
6. Conectar SSH y configurar firewall server 2 → **~5 segundos**
7. Esperar health checks → **~30 segundos**
8. Verificar y probar → **~1 minuto**

**TOTAL: ~8 minutos** desde `terraform apply` hasta infraestructura completamente funcional.

---

## 🐛 SOLUCIONES ALTERNATIVAS (PENDIENTES DE IMPLEMENTAR)

### Opción 1: Deshabilitar firewalld en user_data
```bash
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

### Opción 2: Usar iptables directo
```bash
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo service iptables save
```

### Opción 3: Agregar delay en user_data
```bash
sleep 30  # Esperar a que el sistema esté completamente iniciado
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

### Opción 4: Verificar en user_data script
```bash
# Esperar a que firewalld esté listo
until systemctl is-active firewalld; do
  sleep 5
done
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```
