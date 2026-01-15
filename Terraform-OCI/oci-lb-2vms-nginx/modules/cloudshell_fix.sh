#!/bin/bash
# ==============================================================================
# COMANDOS PARA CLOUD SHELL - Configurar Web Servers
# COPIAR Y PEGAR EN CLOUD SHELL DE OCI
# ==============================================================================

IP_1="172.17.2.148"
IP_2="172.17.2.129"

echo "=================================================================="
echo "CONFIGURANDO WEB SERVERS"
echo "=================================================================="

# Web Server 1
ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no opc@$IP_1 << 'EOF'
echo "opc:admin" | sudo chpasswd
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl start nginx
sudo systemctl enable nginx
echo "✅ Web Server 1 configurado"
sudo systemctl status nginx --no-pager
curl -I http://localhost
EOF

# Web Server 2
ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no opc@$IP_2 << 'EOF'
echo "opc:admin" | sudo chpasswd
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl start nginx
sudo systemctl enable nginx
echo "✅ Web Server 2 configurado"
sudo systemctl status nginx --no-pager
curl -I http://localhost
EOF

echo ""
echo "✅ COMPLETADO - Credenciales: opc/admin"
