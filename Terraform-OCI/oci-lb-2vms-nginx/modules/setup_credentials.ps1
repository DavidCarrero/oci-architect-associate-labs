# ==============================================================================
# SCRIPT PARA CONFIGURAR CREDENCIALES EN INSTANCIAS EXISTENTES (PowerShell)
# ==============================================================================
# Este script se conecta vía SSH a las instancias y configura:
# - Usuario: opc
# - Contraseña: admin
# ==============================================================================

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "CONFIGURANDO CREDENCIALES EN INSTANCIAS EXISTENTES" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Variables
$SSH_KEY = "C:\Users\practicante_dtic2\.ssh\id_ed25519_utb"
$SESSION_1 = "ocid1.bastionsession.oc1.sa-bogota-1.amaaaaaay7v6coqayw5ba3esarf2d25us7fpf354dq6zhqzsnixjfvbr342a"
$SESSION_2 = "ocid1.bastionsession.oc1.sa-bogota-1.amaaaaaay7v6coqapeaffwmvbzelze3oj355utgxwgsblza2ailivazjfdoa"
$BASTION_HOST = "host.bastion.sa-bogota-1.oci.oraclecloud.com"
$IP_1 = "172.17.2.148"
$IP_2 = "172.17.2.129"

# Verificar que SSH esté disponible
if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: ssh no esta disponible. Instala OpenSSH o usa Git Bash." -ForegroundColor Red
    exit 1
}

# Verificar que la key exista
if (-not (Test-Path $SSH_KEY)) {
    Write-Host "ERROR: No se encuentra la SSH key en: $SSH_KEY" -ForegroundColor Red
    exit 1
}

Write-Host "Verificacion completada. Iniciando configuracion..." -ForegroundColor Green
Write-Host ""

# Comandos a ejecutar en las instancias
$SETUP_SCRIPT = @'
echo "Configurando credenciales..."
echo "opc:admin" | sudo chpasswd
echo "Contraseña establecida para usuario opc: admin"
echo ""
echo "Habilitando autenticación por contraseña en SSH..."
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
if ! sudo grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
    echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config > /dev/null
fi
sudo systemctl restart sshd
echo "SSH configurado para aceptar contraseñas"
echo ""
echo "CREDENCIALES:"
echo "   Usuario: opc"
echo "   Contraseña: admin"
'@

# Función para configurar una instancia
function Configure-Instance {
    param(
        [string]$ServerName,
        [string]$SessionId,
        [string]$IP
    )
    
    Write-Host "==================================================================" -ForegroundColor Yellow
    Write-Host "Configurando $ServerName ($IP)" -ForegroundColor Yellow
    Write-Host "==================================================================" -ForegroundColor Yellow
    
    try {
        # Crear el comando SSH
        $proxyCommand = "ssh -i `"$SSH_KEY`" -W %h:%p -p 22 $SessionId@$BASTION_HOST"
        
        # Ejecutar comandos remotamente
        $SETUP_SCRIPT | ssh -i "$SSH_KEY" `
            -o StrictHostKeyChecking=no `
            -o UserKnownHostsFile=NUL `
            -o ProxyCommand="$proxyCommand" `
            opc@$IP
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Configuracion de $ServerName completada" -ForegroundColor Green
        } else {
            Write-Host "ERROR al configurar $ServerName (Exit code: $LASTEXITCODE)" -ForegroundColor Red
        }
    } catch {
        Write-Host "ERROR al conectar a $ServerName : $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

# Configurar ambas instancias
Configure-Instance -ServerName "Web Server 1" -SessionId $SESSION_1 -IP $IP_1
Configure-Instance -ServerName "Web Server 2" -SessionId $SESSION_2 -IP $IP_2

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "CONFIGURACION COMPLETADA" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "CREDENCIALES PARA AMBAS INSTANCIAS:" -ForegroundColor Yellow
Write-Host "   Usuario: opc" -ForegroundColor White
Write-Host "   Contraseña: admin" -ForegroundColor White
Write-Host ""
Write-Host "Ahora puedes conectarte:" -ForegroundColor Yellow
Write-Host "1. Via consola serial de OCI" -ForegroundColor White
Write-Host "2. Via SSH con contraseña (si tienes cliente que lo soporte)" -ForegroundColor White
Write-Host "3. Via SSH con key (metodo original)" -ForegroundColor White
Write-Host ""
Write-Host "NOTA: Para conectar via SSH con contraseña:" -ForegroundColor Yellow
Write-Host '  ssh opc@<ip> -o ProxyCommand="..."' -ForegroundColor Gray
Write-Host "  (Te pedira la contraseña: admin)" -ForegroundColor Gray
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
