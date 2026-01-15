# ============================================================================
# SCRIPT DE VERIFICACION DE SERVIDORES WEB
# ============================================================================
# Este script verifica el estado de las instancias y nginx

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "VERIFICACION DE SERVIDORES WEB" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar estado de las instancias
Write-Host "Estado de las instancias:" -ForegroundColor Yellow
terraform output web_server_state
Write-Host ""

# 2. Verificar tiempo de creacion
Write-Host "Tiempo de creacion:" -ForegroundColor Yellow
$timeCreated = terraform output -json web_server_time_created | ConvertFrom-Json
foreach ($time in $timeCreated) {
    $created = [DateTime]::Parse($time)
    $elapsed = (Get-Date).ToUniversalTime() - $created
    $minutes = [Math]::Round($elapsed.TotalMinutes, 1)
    Write-Host "  - Creada hace: $minutes minutos" -ForegroundColor White
}
Write-Host ""

# 3. Obtener IPs
Write-Host "IPs de los servidores:" -ForegroundColor Yellow
$ip1 = terraform output -raw web_server_1_private_ip
$ip2 = terraform output -raw web_server_2_private_ip
$lbIP = (terraform output -json load_balancer_public_ip | ConvertFrom-Json)[0]
Write-Host "  - Web Server 1: $ip1" -ForegroundColor White
Write-Host "  - Web Server 2: $ip2" -ForegroundColor White
Write-Host "  - Load Balancer: $lbIP" -ForegroundColor White
Write-Host ""

# 4. Comandos SSH
Write-Host "Comandos SSH para conectar:" -ForegroundColor Yellow
$sessionId1 = terraform output -raw web_server_1_session_id
Write-Host "  Web Server 1:" -ForegroundColor Cyan
Write-Host "  ssh -i C:\Users\practicante_dtic2\.ssh\id_ed25519_utb -o ProxyCommand=`"ssh -i C:\Users\practicante_dtic2\.ssh\id_ed25519_utb -W %h:%p -p 22 $sessionId1@host.bastion.sa-bogota-1.oci.oraclecloud.com`" opc@$ip1" -ForegroundColor Gray
Write-Host ""

# 5. Comandos para ejecutar dentro de las instancias
Write-Host "Comandos para ejecutar DENTRO de las instancias via SSH:" -ForegroundColor Yellow
Write-Host "  1. Ver logs de cloud-init:" -ForegroundColor Cyan
Write-Host "     sudo cat /var/log/user-data.log" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Verificar estado de nginx:" -ForegroundColor Cyan
Write-Host "     sudo systemctl status nginx" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Verificar puerto 80:" -ForegroundColor Cyan
Write-Host "     sudo netstat -tlnp | grep :80" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. Probar HTTP localmente:" -ForegroundColor Cyan
Write-Host "     curl http://localhost" -ForegroundColor Gray
Write-Host ""

# 6. Intentar acceder al Load Balancer
Write-Host "Probando conectividad al Load Balancer..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://$lbIP" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  Load Balancer responde correctamente!" -ForegroundColor Green
    Write-Host "  Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Contenido de la respuesta:" -ForegroundColor Yellow
    $contentLength = [Math]::Min(500, $response.Content.Length)
    Write-Host $response.Content.Substring(0, $contentLength)
} catch {
    Write-Host "  Load Balancer NO responde (backends en CRITICAL)" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Posibles causas:" -ForegroundColor Yellow
    Write-Host "     1. Nginx aun no esta instalado (cloud-init en progreso)" -ForegroundColor White
    Write-Host "     2. Firewall bloqueando puerto 80" -ForegroundColor White
    Write-Host "     3. Nginx no esta corriendo" -ForegroundColor White
    Write-Host ""
    Write-Host "  Solucion:" -ForegroundColor Yellow
    Write-Host "     - Conectate via SSH y verifica los logs" -ForegroundColor White
    Write-Host "     - Espera 5-10 minutos si las instancias son recientes" -ForegroundColor White
}
Write-Host ""

# 7. Resumen
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "RESUMEN" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

$minutesElapsed = ([DateTime]::Now.ToUniversalTime() - [DateTime]::Parse($timeCreated[0])).TotalMinutes
if ($minutesElapsed -lt 5) {
    Write-Host "Las instancias son MUY recientes: $([Math]::Round($minutesElapsed, 1)) minutos" -ForegroundColor Yellow
    Write-Host "Cloud-init probablemente aun esta ejecutandose." -ForegroundColor Yellow
    Write-Host "ESPERA 5-10 minutos antes de verificar." -ForegroundColor Yellow
} elseif ($minutesElapsed -lt 10) {
    Write-Host "Las instancias tienen: $([Math]::Round($minutesElapsed, 1)) minutos" -ForegroundColor Yellow
    Write-Host "Nginx deberia estar instalandose o ya instalado." -ForegroundColor Yellow
    Write-Host "Plugin Bastion deberia estar activandose." -ForegroundColor Yellow
} else {
    Write-Host "Las instancias tienen: $([Math]::Round($minutesElapsed, 1)) minutos" -ForegroundColor Green
    Write-Host "Todo deberia estar listo. Si no funciona, hay un problema." -ForegroundColor Green
}

Write-Host ""
Write-Host "Ver documentacion completa: VALIDACION_INSTALACION.md" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

