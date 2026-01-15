# ==============================================================================
# SCRIPT: Generar comandos para Cloud Shell
# ==============================================================================
# Este script genera todos los comandos que necesitas copiar y pegar
# en Cloud Shell de OCI para configurar las instancias
# ==============================================================================

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "COMANDOS PARA CLOUD SHELL DE OCI" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Obtener IPs desde Terraform
$IP_1 = terraform output -raw web_server_1_private_ip
$IP_2 = terraform output -raw web_server_2_private_ip

Write-Host "PASO 1: Abrir Cloud Shell en OCI Console" -ForegroundColor Yellow
Write-Host "  - Ve a https://cloud.oracle.com" -ForegroundColor White
Write-Host "  - Click en el icono >_ (Developer tools) en la esquina superior derecha" -ForegroundColor White
Write-Host "  - Selecciona 'Cloud Shell'" -ForegroundColor White
Write-Host "  - Espera 1-2 minutos a que inicie" -ForegroundColor White
Write-Host ""

Write-Host "PASO 2: Copia tu SSH key a Cloud Shell" -ForegroundColor Yellow
Write-Host ""
Write-Host "Opcion A: Subir archivo via Upload en Cloud Shell" -ForegroundColor Cyan
Write-Host "  1. Click en el icono de Upload en Cloud Shell" -ForegroundColor White
Write-Host "  2. Selecciona: C:\Users\practicante_dtic2\.ssh\id_ed25519_utb" -ForegroundColor White
Write-Host "  3. Ejecuta en Cloud Shell:" -ForegroundColor White
Write-Host @"
mkdir -p ~/.ssh
mv id_ed25519_utb ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
"@ -ForegroundColor Gray
Write-Host ""

Write-Host "Opcion B: Copiar contenido manualmente" -ForegroundColor Cyan
Write-Host "  1. Abre en tu PC: C:\Users\practicante_dtic2\.ssh\id_ed25519_utb" -ForegroundColor White
Write-Host "  2. Copia TODO el contenido" -ForegroundColor White
Write-Host "  3. En Cloud Shell, ejecuta:" -ForegroundColor White
Write-Host @"
mkdir -p ~/.ssh
cat > ~/.ssh/id_ed25519 << 'EOF'
[PEGA AQUI EL CONTENIDO DE LA KEY]
EOF
chmod 600 ~/.ssh/id_ed25519
"@ -ForegroundColor Gray
Write-Host ""

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "PASO 3: COMANDOS PARA EJECUTAR EN CLOUD SHELL" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Copia y pega estos comandos en Cloud Shell:" -ForegroundColor White
Write-Host ""

# Generar el script completo
$cloudShellScript = @"
#!/bin/bash
# ==============================================================================
# Script de configuracion y verificacion de Web Servers
# ==============================================================================

echo "=================================================================="
echo "CONFIGURANDO Y VERIFICANDO WEB SERVERS"
echo "=================================================================="
echo ""

# Variables
IP_1="$IP_1"
IP_2="$IP_2"

# ==============================================================================
# CONFIGURAR CREDENCIALES
# ==============================================================================

echo "Configurando Web Server 1 (\$IP_1)..."
ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no opc@\$IP_1 << 'ENDSSH'
echo "Estableciendo contraseña para usuario opc..."
echo "opc:admin" | sudo chpasswd
echo "Habilitando autenticacion por contraseña..."
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
if ! sudo grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
    echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
fi
sudo systemctl restart sshd
echo "✅ Credenciales configuradas: opc/admin"
ENDSSH

echo ""
echo "Configurando Web Server 2 (\$IP_2)..."
ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no opc@\$IP_2 << 'ENDSSH'
echo "Estableciendo contraseña para usuario opc..."
echo "opc:admin" | sudo chpasswd
echo "Habilitando autenticacion por contraseña..."
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
if ! sudo grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
    echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
fi
sudo systemctl restart sshd
echo "✅ Credenciales configuradas: opc/admin"
ENDSSH

# ==============================================================================
# VERIFICAR Y SOLUCIONAR NGINX
# ==============================================================================

echo ""
echo "=================================================================="
echo "VERIFICANDO NGINX EN WEB SERVER 1"
echo "=================================================================="
ssh -i ~/.ssh/id_ed25519 opc@\$IP_1 << 'ENDSSH'
echo "--- Estado de nginx ---"
sudo systemctl status nginx --no-pager -l || echo "nginx no esta activo"
echo ""
echo "--- Puerto 80 ---"
sudo netstat -tlnp | grep :80 || echo "Puerto 80 no esta escuchando"
echo ""
echo "--- Test HTTP local ---"
curl -I http://localhost 2>&1 | head -5
echo ""
echo "--- Verificando firewall ---"
sudo firewall-cmd --list-all 2>/dev/null || echo "firewalld no esta activo"
echo ""
echo "--- Ultimas lineas de cloud-init log ---"
sudo tail -20 /var/log/user-data.log
echo ""
echo "--- SOLUCION: Deshabilitando firewall e iniciando nginx ---"
sudo systemctl stop firewalld 2>/dev/null
sudo systemctl disable firewalld 2>/dev/null
sudo systemctl start nginx
sudo systemctl enable nginx
echo ""
echo "--- Verificacion final ---"
sudo systemctl status nginx --no-pager
curl -I http://localhost
ENDSSH

echo ""
echo "=================================================================="
echo "VERIFICANDO NGINX EN WEB SERVER 2"
echo "=================================================================="
ssh -i ~/.ssh/id_ed25519 opc@\$IP_2 << 'ENDSSH'
echo "--- Estado de nginx ---"
sudo systemctl status nginx --no-pager -l || echo "nginx no esta activo"
echo ""
echo "--- Puerto 80 ---"
sudo netstat -tlnp | grep :80 || echo "Puerto 80 no esta escuchando"
echo ""
echo "--- Test HTTP local ---"
curl -I http://localhost 2>&1 | head -5
echo ""
echo "--- SOLUCION: Deshabilitando firewall e iniciando nginx ---"
sudo systemctl stop firewalld 2>/dev/null
sudo systemctl disable firewalld 2>/dev/null
sudo systemctl start nginx
sudo systemctl enable nginx
echo ""
echo "--- Verificacion final ---"
sudo systemctl status nginx --no-pager
curl -I http://localhost
ENDSSH

echo ""
echo "=================================================================="
echo "✅ CONFIGURACION COMPLETADA"
echo "=================================================================="
echo ""
echo "CREDENCIALES:"
echo "  Usuario: opc"
echo "  Contraseña: admin"
echo ""
echo "IPs:"
echo "  Web Server 1: \$IP_1"
echo "  Web Server 2: \$IP_2"
echo ""
echo "Para conectar directamente:"
echo "  ssh opc@\$IP_1  (contraseña: admin)"
echo "  ssh opc@\$IP_2  (contraseña: admin)"
echo ""
echo "=================================================================="
"@

# Guardar en archivo para fácil acceso
$scriptPath = "cloud_shell_commands.sh"
$cloudShellScript | Out-File -FilePath $scriptPath -Encoding utf8 -NoNewline

Write-Host "==================================================================" -ForegroundColor Green
Write-Host "SCRIPT GENERADO: $scriptPath" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "OPCIONES PARA USAR EL SCRIPT:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Opcion 1: Copiar contenido del archivo" -ForegroundColor Cyan
Write-Host "  1. Abre: $scriptPath" -ForegroundColor White
Write-Host "  2. Copia TODO el contenido" -ForegroundColor White
Write-Host "  3. Pega en Cloud Shell" -ForegroundColor White
Write-Host ""
Write-Host "Opcion 2: Ver contenido ahora" -ForegroundColor Cyan
Write-Host "  Get-Content $scriptPath" -ForegroundColor White
Write-Host ""
Write-Host "Opcion 3: Subir archivo a Cloud Shell" -ForegroundColor Cyan
Write-Host "  1. En Cloud Shell, click en Upload" -ForegroundColor White
Write-Host "  2. Selecciona: $scriptPath" -ForegroundColor White
Write-Host "  3. Ejecuta: bash cloud_shell_commands.sh" -ForegroundColor White
Write-Host ""

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "RESUMEN DE IPS" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  Web Server 1: $IP_1" -ForegroundColor White
Write-Host "  Web Server 2: $IP_2" -ForegroundColor White
Write-Host ""
Write-Host "Despues de ejecutar el script, las credenciales seran:" -ForegroundColor Yellow
Write-Host "  Usuario: opc" -ForegroundColor White
Write-Host "  Contraseña: admin" -ForegroundColor White
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
