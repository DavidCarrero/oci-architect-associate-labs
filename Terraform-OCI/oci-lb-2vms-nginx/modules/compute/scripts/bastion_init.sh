#!/bin/bash
# ==============================================================================
# BASTION HOST INITIALIZATION SCRIPT
# ==============================================================================
# Este script configura el bastion host para acceso SSH a las instancias privadas

# Registrar todas las acciones en un log
exec > >(tee -a /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "Iniciando configuración del Bastion Host"
echo "=========================================="

# Actualizar el sistema (DESHABILITADO para acelerar deployment)
# echo "Actualizando paquetes del sistema..."
# yum update -y

# Instalar herramientas útiles
echo "Instalando herramientas útiles..."
yum install -y \
    vim \
    wget \
    curl \
    net-tools \
    bind-utils \
    telnet \
    nc

# Configurar mensaje de bienvenida
echo "Configurando mensaje de bienvenida..."
cat > /etc/motd <<'EOF'

╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                    🔐 BASTION HOST                            ║
║                                                                ║
║  Este servidor es el punto de entrada SSH para acceder a      ║
║  las instancias privadas (Web Servers).                       ║
║                                                                ║
║  INSTRUCCIONES:                                                ║
║  - Para conectar a Web Server 1: ssh opc@<IP_PRIVADA_WS1>     ║
║  - Para conectar a Web Server 2: ssh opc@<IP_PRIVADA_WS2>     ║
║                                                                ║
║  SEGURIDAD:                                                    ║
║  - No almacenar claves privadas en este servidor              ║
║  - Usar SSH Agent Forwarding si es necesario                  ║
║  - Revisar logs de acceso regularmente                        ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

EOF

# Configurar SSH para ser más seguro
echo "Mejorando configuración de SSH..."
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 300/g' /etc/ssh/sshd_config
sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 2/g' /etc/ssh/sshd_config
systemctl restart sshd

# Configurar firewall para permitir solo SSH
echo "Configurando firewall..."
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# Crear directorio para logs de conexiones
echo "Configurando logging..."
mkdir -p /var/log/bastion
chmod 755 /var/log/bastion

# Script de monitoreo de conexiones SSH
cat > /usr/local/bin/log-ssh-connections.sh <<'LOGSCRIPT'
#!/bin/bash
# Log SSH connections
while read line; do
    if echo "$line" | grep -q "Accepted publickey"; then
        USER=$(echo "$line" | awk '{print $9}')
        IP=$(echo "$line" | awk '{print $11}')
        echo "$(date '+%Y-%m-%d %H:%M:%S') - SSH Login: User=$USER from IP=$IP" >> /var/log/bastion/connections.log
    fi
done < <(tail -f /var/log/secure)
LOGSCRIPT

chmod +x /usr/local/bin/log-ssh-connections.sh

echo "=========================================="
echo "✅ Bastion Host configurado exitosamente"
echo "=========================================="
