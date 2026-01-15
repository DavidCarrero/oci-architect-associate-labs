# 🔐 GUÍA DE CONEXIÓN SSH A LAS INSTANCIAS

## ✅ MÉTODO RECOMENDADO: SSH con Key (Ya configurado)

Las instancias usan autenticación por SSH key (más seguro que contraseñas).

### 📋 PASOS PARA CONECTAR

**1. Abrir PowerShell o Git Bash**

**2. Ejecutar el comando SSH:**

```bash
# Web Server 1:
ssh -i C:\Users\practicante_dtic2\.ssh\id_ed25519_utb -o ProxyCommand="ssh -i C:\Users\practicante_dtic2\.ssh\id_ed25519_utb -W %h:%p -p 22 ocid1.bastionsession.oc1.sa-bogota-1.amaaaaaay7v6coqayw5ba3esarf2d25us7fpf354dq6zhqzsnixjfvbr342a@host.bastion.sa-bogota-1.oci.oraclecloud.com" opc@172.17.2.148
```

**3. Si pide confirmar fingerprint, escribir `yes`**

**4. Ya estás dentro! Usuario: `opc` (con permisos sudo)**

---

## 🔧 CONFIGURAR CONTRASEÑA (Si realmente la necesitas)

### Opción A: Desde SSH (Manual - RÁPIDO)

**1. Conéctate vía SSH (comando de arriba)**

**2. Una vez dentro, establece contraseña para `opc`:**
```bash
# Establecer contraseña para el usuario opc
sudo passwd opc
# Te pedirá ingresar la contraseña 2 veces
# Ejemplo: admin123
```

**3. Habilitar autenticación por contraseña en SSH (opcional):**
```bash
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

**4. Ahora puedes usar usuario/contraseña desde la consola serial de OCI**

---

### Opción B: Modificar script de inicialización (Recrear instancias)

Si quieres que las instancias tengan contraseña desde el inicio, puedo modificar el script `web_server_init.sh` para:
- Crear usuario: `admin` / contraseña: `admin`
- O establecer contraseña para `opc`

**⚠️ ADVERTENCIA:** Esto requiere destruir y recrear las instancias.

---

## 🖥️ CONECTAR VÍA CONSOLA SERIAL (OCI Console)

Si prefieres usar la consola serial de OCI:

**1. Ir a OCI Console:**
- Compute → Instances → web-server-1

**2. Click en "Console Connection"**

**3. Crear conexión serial**

**4. Una vez creada, necesitas:**
- Usuario: `opc`
- Contraseña: (debes establecerla primero vía SSH - ver Opción A)

---

## 💡 RECOMENDACIÓN

**La forma más segura y rápida es usar SSH con keys (ya configurado).**

Si realmente necesitas contraseñas:
1. Conéctate vía SSH primero (no requiere contraseña)
2. Establece la contraseña desde dentro con `sudo passwd opc`
3. Listo para usar consola serial

---

## 🆘 PROBLEMAS COMUNES

### "Permission denied (publickey)"
- Verifica que la key esté en: `C:\Users\practicante_dtic2\.ssh\id_ed25519_utb`
- Verifica permisos de la key: `icacls C:\Users\practicante_dtic2\.ssh\id_ed25519_utb`

### "Connection timeout"
- Las sesiones Bastion pueden expirar (duran 3 horas)
- Ejecuta: `terraform apply` para recrearlas

### "Host key verification failed"
- Ejecuta: `ssh-keyscan -H host.bastion.sa-bogota-1.oci.oraclecloud.com >> ~/.ssh/known_hosts`

---

## 📞 COMANDOS ÚTILES

```powershell
# Ver comandos SSH generados por Terraform
terraform output web_server_1_ssh_command
terraform output web_server_2_ssh_command

# Recrear sesiones Bastion si expiraron
terraform destroy -target=module.bastion.oci_bastion_session.web_server_1
terraform apply

# Ver estado de las instancias
terraform output web_server_state
```
