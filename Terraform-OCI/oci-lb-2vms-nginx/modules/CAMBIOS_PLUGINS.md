# ✅ CORRECCIÓN APLICADA: Plugins de Oracle Cloud Agent

## 🔧 CAMBIOS REALIZADOS

Se actualizó el archivo: `modules/compute/instances.tf`

**Plugins habilitados en las instancias:**

1. ✅ **Bastion** - Para sesiones SSH vía Bastion Service
2. ✅ **Management Agent** - Para gestión remota (Run Command)
3. ✅ **OS Management Service Agent** - Para Run Command de OCI

---

## 📋 APLICAR LOS CAMBIOS

### Opción 1: Desde el directorio raíz del proyecto

```powershell
# Ir al directorio raíz (donde está main.tf)
cd C:\Users\practicante_dtic2\Documents\Work\terraform-proyects\oci-architect-associate-labs\Terraform-OCI\oci-lb-2vms-nginx

# Aplicar cambios
terraform apply -auto-approve
```

### Opción 2: Si terraform no está en PATH

Busca donde instalaste terraform y usa la ruta completa, por ejemplo:

```powershell
& "C:\ruta\a\terraform.exe" apply -auto-approve
```

---

## ⚠️ IMPORTANTE

Los cambios se aplicarán a las instancias **sin recrearlas**. Terraform modificará la configuración del Oracle Cloud Agent.

**Tiempo estimado:**
- Apply: 2-3 minutos
- Plugins activos: 5-10 minutos adicionales

**Después del apply:**
1. Los plugins tardan 5-10 minutos en activarse
2. Puedes verificar en OCI Console:
   - Compute → Instances → web-server-1
   - Scroll hasta "Oracle Cloud Agent"
   - Verifica que estén ENABLED y RUNNING:
     - Bastion
     - Management Agent
     - OS Management Service Agent

---

## 🎯 BENEFICIOS

Con estos plugins habilitados:

✅ **Run Command funcionará** (desde OCI Console)
✅ **Sesiones Bastion funcionarán** (SSH remoto)
✅ **Gestión remota completa** desde OCI Console

---

## 📊 VERIFICAR EN OCI CONSOLE

Después de aplicar terraform y esperar 10 minutos:

1. **Ir a:** Compute → Instances → web-server-1 (o web-server-2)
2. **Scroll down** hasta "Oracle Cloud Agent"
3. **Verificar plugins:**

| Plugin | Estado esperado |
|--------|----------------|
| Bastion | ✅ Enabled, Running |
| Management Agent | ✅ Enabled, Running |
| OS Management Service Agent | ✅ Enabled, Running |

---

## 🔍 PROBAR RUN COMMAND

Una vez que los plugins estén RUNNING:

1. **Ir a:** Compute → Instances → web-server-1
2. **Click en:** "Run Command" en el menú izquierdo
3. **Create command** con este script:
```bash
# Configurar contraseña y nginx
echo "opc:admin" | sudo chpasswd
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl start nginx
sudo systemctl enable nginx
echo "✅ Configurado: opc/admin"
sudo systemctl status nginx
```

4. **Ejecutar** y esperar 2-5 minutos
5. **Ver resultados** en la misma página

---

## 🚀 SIGUIENTE PASO

Mientras esperas a que terraform aplique los cambios, puedes usar **Cloud Shell** para configurar inmediatamente:

```bash
# En Cloud Shell de OCI
ssh -i ~/.ssh/id_ed25519 opc@172.17.2.148 "echo 'opc:admin' | sudo chpasswd && sudo systemctl stop firewalld && sudo systemctl start nginx"
ssh -i ~/.ssh/id_ed25519 opc@172.17.2.129 "echo 'opc:admin' | sudo chpasswd && sudo systemctl stop firewalld && sudo systemctl start nginx"
```

Ver: [CONECTAR_CLOUD_SHELL.md](CONECTAR_CLOUD_SHELL.md) o [cloudshell_fix.sh](cloudshell_fix.sh)

---

**Archivo modificado:** [instances.tf](compute/instances.tf#L75-L96)
