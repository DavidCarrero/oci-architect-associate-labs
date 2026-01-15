#!/bin/bash
# ==============================================================================
# WEB SERVER INITIALIZATION SCRIPT - FIXED VERSION
# ==============================================================================
# Este script instala nginx y configura el firewall de manera robusta
# Registrar todas las acciones en un log
exec > >(tee -a /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "Iniciando configuración del Web Server ${server_number}"
echo "Fecha: $(date)"
echo "=========================================="

# ==============================================================================
# PASO 1: DESHABILITAR SELINUX TEMPORALMENTE (para evitar problemas)
# ==============================================================================
echo "Configurando SELinux..."
setenforce 0 2>/dev/null || true

# ==============================================================================
# PASO 2: INSTALAR NGINX
# ==============================================================================
echo "Instalando nginx..."
yum install -y nginx

# Obtener información de la instancia
INSTANCE_ID=$(curl -s http://169.254.169.254/opc/v1/instance/id)
INSTANCE_NAME=$(hostname)
PRIVATE_IP=$(hostname -I | awk '{print $1}')
AVAILABILITY_DOMAIN=$(curl -s http://169.254.169.254/opc/v1/instance/availabilityDomain)

# ==============================================================================
# PASO 3: CREAR PÁGINA HTML PERSONALIZADA
# ==============================================================================
echo "Creando página web personalizada..."
cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web Server ${server_number}</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            background: white;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            max-width: 600px;
            text-align: center;
        }
        h1 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        .server-number {
            font-size: 4em;
            font-weight: bold;
            color: #764ba2;
            margin: 20px 0;
        }
        .info-box {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin: 15px 0;
            text-align: left;
        }
        .info-label {
            font-weight: bold;
            color: #333;
        }
        .info-value {
            color: #666;
            font-family: 'Courier New', monospace;
            word-break: break-all;
        }
        .footer {
            margin-top: 30px;
            color: #999;
            font-size: 0.9em;
        }
        .status {
            display: inline-block;
            width: 10px;
            height: 10px;
            background: #28a745;
            border-radius: 50%;
            margin-right: 5px;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Web Server</h1>
        <div class="server-number">#${server_number}</div>
        
        <div class="info-box">
            <div class="info-label">📌 Hostname:</div>
            <div class="info-value">$INSTANCE_NAME</div>
        </div>
        
        <div class="info-box">
            <div class="info-label">🌐 IP Privada:</div>
            <div class="info-value">$PRIVATE_IP</div>
        </div>
        
        <div class="info-box">
            <div class="info-label">🆔 Instance ID:</div>
            <div class="info-value">$INSTANCE_ID</div>
        </div>
        
        <div class="info-box">
            <div class="info-label">📍 Availability Domain:</div>
            <div class="info-value">$AVAILABILITY_DOMAIN</div>
        </div>
        
        <div class="footer">
            <span class="status"></span>
            <strong>Estado:</strong> Activo | <strong>Load Balancer:</strong> Round Robin
        </div>
    </div>
</body>
</html>
EOF

# ==============================================================================
# PASO 4: CONFIGURAR NGINX
# ==============================================================================
echo "Configurando nginx..."
cat > /etc/nginx/nginx.conf <<'NGINXCONF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        location / {
            index  index.html index.htm;
        }

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
}
NGINXCONF

# ==============================================================================
# PASO 5: CONFIGURAR FIREWALL - MÉTODO ROBUSTO
# ==============================================================================
echo "=========================================="
echo "Configurando firewall..."
echo "=========================================="

# OPCIÓN 1: Deshabilitar firewalld completamente (más confiable para testing)
echo "Deshabilitando firewalld..."
systemctl stop firewalld 2>/dev/null || true
systemctl disable firewalld 2>/dev/null || true

# OPCIÓN 2: Usar iptables directo (más confiable)
echo "Configurando iptables..."
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT

# Guardar reglas de iptables
iptables-save > /etc/sysconfig/iptables 2>/dev/null || true

echo "✅ Firewall configurado - puerto 80 y 443 abiertos"

# ==============================================================================
# PASO 6: HABILITAR E INICIAR NGINX
# ==============================================================================
echo "Habilitando y iniciando nginx..."
systemctl enable nginx
systemctl start nginx

# Esperar a que nginx esté completamente iniciado
sleep 3

# ==============================================================================
# PASO 7: VERIFICACIONES
# ==============================================================================
echo "=========================================="
echo "Verificando configuración..."
echo "=========================================="

# Verificar nginx
echo "Estado de nginx:"
systemctl status nginx --no-pager -l || true

# Verificar puerto 80
echo "Puerto 80:"
netstat -tlnp | grep :80 || ss -tlnp | grep :80 || true

# Prueba HTTP local
echo "Probando HTTP local..."
sleep 2
curl -I http://localhost 2>/dev/null || echo "⚠️ Curl falló, pero nginx podría estar iniciando"

# Verificar firewall
echo "Estado del firewall:"
systemctl is-active firewalld && echo "Firewalld: ACTIVO" || echo "Firewalld: DESACTIVADO"

# Verificar reglas iptables
echo "Reglas iptables:"
iptables -L INPUT -n | grep -E "tcp dpt:(80|443)" || true

# ==============================================================================
# PASO 8: CONFIGURAR CREDENCIALES DE ACCESO
# ==============================================================================
echo "=========================================="
echo "Configurando credenciales de acceso..."
echo "=========================================="

# Establecer contraseña para usuario opc (admin/admin)
echo "Estableciendo contraseña para usuario 'opc'..."
echo "opc:admin" | chpasswd
if [ $? -eq 0 ]; then
    echo "✅ Contraseña establecida para usuario 'opc': admin"
else
    echo "⚠️ Error al establecer contraseña para opc"
fi

# Habilitar autenticación por contraseña en SSH (opcional, comentar si no se necesita)
echo "Habilitando autenticación por contraseña en SSH..."
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Asegurar que PasswordAuthentication esté configurado
if ! grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
fi

# Reiniciar SSH para aplicar cambios
systemctl restart sshd
echo "✅ SSH configurado para aceptar contraseñas"

# ==============================================================================
# PASO 9: RESULTADO FINAL
# ==============================================================================
echo "=========================================="
echo "✅ Web Server ${server_number} configurado"
echo "=========================================="
echo "Logs: /var/log/user-data.log"
echo "Nginx: $(systemctl is-active nginx)"
echo "Puerto 80: $(netstat -tln | grep -c ':80' || echo '0') listener(s)"
echo ""
echo "🔐 CREDENCIALES DE ACCESO:"
echo "   Usuario: opc"
echo "   Contraseña: admin"
echo ""
echo "Fecha completado: $(date)"
echo "=========================================="
