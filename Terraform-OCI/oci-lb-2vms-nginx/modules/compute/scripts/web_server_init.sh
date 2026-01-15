#!/bin/bash
# ==============================================================================
# WEB SERVER INITIALIZATION SCRIPT
# ==============================================================================
# Este script se ejecuta automáticamente al crear la instancia
# Instala y configura un servidor web simple que muestra información de la instancia

# Registrar todas las acciones en un log
exec > >(tee -a /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "Iniciando configuración del Web Server ${server_number}"
echo "=========================================="

# Actualizar el sistema (DESHABILITADO para acelerar deployment)
# echo "Actualizando paquetes del sistema..."
# yum update -y

# Instalar nginx
echo "Instalando nginx..."
yum install -y nginx

# Obtener información de la instancia
INSTANCE_ID=$(curl -s http://169.254.169.254/opc/v1/instance/id)
INSTANCE_NAME=$(hostname)
PRIVATE_IP=$(hostname -I | awk '{print $1}')
AVAILABILITY_DOMAIN=$(curl -s http://169.254.169.254/opc/v1/instance/availabilityDomain)

# Crear página HTML personalizada
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

# Configurar nginx para escuchar en puerto 80
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

# Habilitar y iniciar nginx
echo "Iniciando nginx..."
systemctl enable nginx
systemctl start nginx

# Configurar firewall - MEJORADO para garantizar ejecución
echo "=========================================="
echo "Configurando firewall..."
echo "=========================================="

# Asegurar que firewalld esté instalado y en ejecución
echo "Verificando firewalld..."
if ! systemctl is-active --quiet firewalld; then
    echo "Firewalld no está activo, iniciando servicio..."
    systemctl start firewalld
    systemctl enable firewalld
fi

# Esperar a que firewalld esté completamente listo (máximo 30 segundos)
echo "Esperando a que firewalld esté listo..."
for i in {1..30}; do
    if systemctl is-active --quiet firewalld; then
        echo "Firewalld está activo después de $i segundos"
        break
    fi
    sleep 1
done

# Verificar si firewalld está corriendo
if systemctl is-active --quiet firewalld; then
    echo "Agregando regla HTTP al firewall..."
    firewall-cmd --permanent --add-service=http
    
    echo "Recargando firewall..."
    firewall-cmd --reload
    
    # Verificar que la regla se aplicó correctamente
    echo "Verificando reglas del firewall..."
    firewall-cmd --list-services
    
    if firewall-cmd --list-services | grep -q http; then
        echo "✅ Regla HTTP agregada exitosamente al firewall"
    else
        echo "⚠️ ADVERTENCIA: La regla HTTP no aparece en la lista"
    fi
else
    echo "⚠️ ADVERTENCIA: Firewalld no está activo, intentando alternativa con iptables..."
    # Alternativa: usar iptables directo
    iptables -I INPUT -p tcp --dport 80 -j ACCEPT
    iptables -I INPUT -p tcp --dport 443 -j ACCEPT
    service iptables save 2>/dev/null || true
    echo "Reglas iptables aplicadas como alternativa"
fi

# Verificar que nginx está escuchando en puerto 80
echo "=========================================="
echo "Verificando nginx..."
echo "=========================================="
netstat -tlnp | grep :80 || ss -tlnp | grep :80
systemctl status nginx --no-pager -l

# Prueba local
echo "Realizando prueba HTTP local..."
sleep 2
curl -I http://localhost || echo "⚠️ Curl falló, pero nginx podría estar iniciando aún"

echo "=========================================="
echo "✅ Web Server ${server_number} configurado exitosamente"
echo "=========================================="
echo "Logs disponibles en: /var/log/user-data.log"
echo "Estado del firewall: $(systemctl is-active firewalld)"
echo "Estado de nginx: $(systemctl is-active nginx)"
echo "=========================================="
