#!/bin/bash
# ==============================================================================
# SCRIPT PARA CONFIGURAR CONTRASEÑAS EN INSTANCIAS EXISTENTES
# ==============================================================================
# Este script se conecta vía SSH a las instancias y configura:
# - Usuario: opc
# - Contraseña: admin
# ==============================================================================

set -e

echo "=================================================================="
echo "CONFIGURANDO CREDENCIALES EN INSTANCIAS EXISTENTES"
echo "=================================================================="
echo ""

# Variables
SSH_KEY="C:/Users/practicante_dtic2/.ssh/id_ed25519_utb"
SESSION_1="ocid1.bastionsession.oc1.sa-bogota-1.amaaaaaay7v6coqayw5ba3esarf2d25us7fpf354dq6zhqzsnixjfvbr342a"
SESSION_2="ocid1.bastionsession.oc1.sa-bogota-1.amaaaaaay7v6coqapeaffwmvbzelze3oj355utgxwgsblza2ailivazjfdoa"
BASTION_HOST="host.bastion.sa-bogota-1.oci.oraclecloud.com"
IP_1="172.17.2.148"
IP_2="172.17.2.129"

# Comandos a ejecutar en las instancias
SETUP_COMMANDS='
echo "Configurando credenciales..."
echo "opc:admin" | sudo chpasswd
echo "✅ Contraseña establecida para usuario opc: admin"
echo ""
echo "Habilitando autenticación por contraseña en SSH..."
sudo sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
if ! sudo grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
    echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
fi
sudo systemctl restart sshd
echo "✅ SSH configurado para aceptar contraseñas"
echo ""
echo "🔐 CREDENCIALES:"
echo "   Usuario: opc"
echo "   Contraseña: admin"
'

echo "=================================================================="
echo "Configurando Web Server 1 ($IP_1)"
echo "=================================================================="
ssh -i "$SSH_KEY" \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o ProxyCommand="ssh -i $SSH_KEY -W %h:%p -p 22 $SESSION_1@$BASTION_HOST" \
    opc@$IP_1 "$SETUP_COMMANDS"

echo ""
echo "=================================================================="
echo "Configurando Web Server 2 ($IP_2)"
echo "=================================================================="
ssh -i "$SSH_KEY" \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o ProxyCommand="ssh -i $SSH_KEY -W %h:%p -p 22 $SESSION_2@$BASTION_HOST" \
    opc@$IP_2 "$SETUP_COMMANDS"

echo ""
echo "=================================================================="
echo "✅ CONFIGURACIÓN COMPLETADA"
echo "=================================================================="
echo ""
echo "🔐 CREDENCIALES PARA AMBAS INSTANCIAS:"
echo "   Usuario: opc"
echo "   Contraseña: admin"
echo ""
echo "Ahora puedes conectarte:"
echo "1. Vía consola serial de OCI"
echo "2. Vía SSH con contraseña"
echo "3. Vía SSH con key (método original)"
echo ""
echo "=================================================================="
