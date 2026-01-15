# 🌐 CONECTAR VIA CLOUD SHELL (Desde Red Interna de OCI)

## ✅ MÉTODO RECOMENDADO: Cloud Shell

Cloud Shell es una terminal integrada en OCI Console que **YA ESTÁ DENTRO DE LA RED DE OCI**.

---

## 📋 PASOS PARA CONECTAR

### 1. Abrir Cloud Shell

1. Ve a OCI Console: https://cloud.oracle.com
2. En la esquina superior derecha, busca el ícono **>_** (Developer tools)
3. Click en **Cloud Shell** (o presiona Alt + >)
4. Espera 1-2 minutos a que inicie

### 2. Subir tu SSH Key a Cloud Shell

```bash
# Opción A: Crear la key manualmente
mkdir -p ~/.ssh
cat > ~/.ssh/id_ed25519 << 'EOF'
-----BEGIN OPENSSH PRIVATE KEY-----
[PEGA AQUI EL CONTENIDO DE TU KEY PRIVADA]
-----END OPENSSH PRIVATE KEY-----
EOF
chmod 600 ~/.ssh/id_ed25519
```

**O bien, pídeme que genere un script para copiar la key**

### 3. Conectar a las instancias (DIRECTO - Sin Bastion)

Desde Cloud Shell puedes conectarte **DIRECTAMENTE** porque estás en la misma VCN:

```bash
# Conectar al Web Server 1 (DIRECTO - Sin proxy)
ssh -i ~/.ssh/id_ed25519 opc@172.17.2.148

# Conectar al Web Server 2 (DIRECTO - Sin proxy)
ssh -i ~/.ssh/id_ed25519 opc@172.17.2.129
```

**✅ No necesitas Bastion porque Cloud Shell está en la red interna de OCI**

---

## 🔧 CONFIGURAR CONTRASEÑAS DESDE CLOUD SHELL

Una vez dentro de Cloud Shell, ejecuta estos comandos:

```bash
# Configurar Web Server 1
ssh -i ~/.ssh/id_ed25519 opc@172.17.2.148 << 'ENDSSH'
echo "opc:admin" | sudo chpasswd
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
echo "✅ Contraseña configurada: admin"
ENDSSH

# Configurar Web Server 2
ssh -i ~/.ssh/id_ed25519 opc@172.17.2.129 << 'ENDSSH'
echo "opc:admin" | sudo chpasswd
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
echo "✅ Contraseña configurada: admin"
ENDSSH
```

---

## 🔍 VERIFICAR NGINX DESDE CLOUD SHELL

```bash
# Verificar Web Server 1
echo "=== WEB SERVER 1 ==="
ssh -i ~/.ssh/id_ed25519 opc@172.17.2.148 << 'ENDSSH'
echo "Estado de nginx:"
sudo systemctl status nginx --no-pager
echo ""
echo "Puerto 80:"
sudo netstat -tlnp | grep :80
echo ""
echo "Test HTTP local:"
curl -I http://localhost
echo ""
echo "Logs de cloud-init (últimas 50 líneas):"
sudo tail -50 /var/log/user-data.log
ENDSSH

# Verificar Web Server 2
echo ""
echo "=== WEB SERVER 2 ==="
ssh -i ~/.ssh/id_ed25519 opc@172.17.2.129 << 'ENDSSH'
echo "Estado de nginx:"
sudo systemctl status nginx --no-pager
echo ""
echo "Puerto 80:"
sudo netstat -tlnp | grep :80
echo ""
echo "Test HTTP local:"
curl -I http://localhost
ENDSSH
```

---

## ⚙️ SOLUCIONAR NGINX SI NO ESTÁ CORRIENDO

```bash
# Si nginx no responde, ejecuta esto desde Cloud Shell
ssh -i ~/.ssh/id_ed25519 opc@172.17.2.148 << 'ENDSSH'
echo "Deshabilitando firewall..."
sudo systemctl stop firewalld
sudo systemctl disable firewalld

echo "Iniciando nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

echo "Verificando..."
sudo systemctl status nginx
curl -I http://localhost
ENDSSH
```

---

## 📝 COPIAR TU SSH KEY A CLOUD SHELL

Si necesitas copiar tu key, sigue estos pasos:

### Opción A: Copiar manualmente

1. En tu PC, abre: `C:\Users\practicante_dtic2\.ssh\id_ed25519`
2. Copia todo el contenido
3. En Cloud Shell:
```bash
mkdir -p ~/.ssh
nano ~/.ssh/id_ed25519
# Pega el contenido
# Ctrl+X, Y, Enter
chmod 600 ~/.ssh/id_ed25519
```

### Opción B: Usar OCI Console para subir archivo

1. En Cloud Shell, click en el ícono de **Upload**
2. Selecciona tu key: `C:\Users\practicante_dtic2\.ssh\id_ed25519`
3. Muévela a .ssh:
```bash
mv id_ed25519 ~/.ssh/
chmod 600 ~/.ssh/id_ed25519
```

---

## ❓ POR QUÉ RUN COMMAND NO HA RESPONDIDO

El "Run Command" tarda porque:

1. **Oracle Cloud Agent** debe estar activo
2. El plugin **"OS Management Service Agent"** debe estar habilitado
3. Puede tardar **5-15 minutos** en ejecutarse
4. La instancia debe tener conectividad con el servicio de OCI

### Verificar estado del Cloud Agent

1. Ve a: **Compute → Instances → web-server-1**
2. Scroll down hasta **"Oracle Cloud Agent"**
3. Verifica que estos plugins estén **ENABLED y RUNNING**:
   - OS Management Service Agent
   - Compute Instance Run Command

### Si Run Command sigue sin responder:

- Espera 10-15 minutos
- Refresca la página
- O usa Cloud Shell (más rápido y confiable)

---

## 🎯 RESUMEN RÁPIDO

```bash
# 1. Abrir Cloud Shell en OCI Console (ícono >_)

# 2. Copiar tu SSH key a Cloud Shell

# 3. Conectar DIRECTAMENTE (sin bastion):
ssh -i ~/.ssh/id_ed25519 opc@172.17.2.148

# 4. Configurar contraseña:
echo "opc:admin" | sudo chpasswd

# 5. Verificar nginx:
sudo systemctl status nginx
curl http://localhost

# 6. Si nginx no funciona:
sudo systemctl stop firewalld
sudo systemctl start nginx
```

---

## 💡 VENTAJAS DE CLOUD SHELL

✅ Ya está dentro de la red de OCI  
✅ No necesitas bastion  
✅ No necesitas configurar SSH en tu PC  
✅ Conexión directa a IPs privadas  
✅ Gratis e integrado en OCI Console  

---

**¿Necesitas que te ayude a copiar la key o ejecutar los comandos?**
