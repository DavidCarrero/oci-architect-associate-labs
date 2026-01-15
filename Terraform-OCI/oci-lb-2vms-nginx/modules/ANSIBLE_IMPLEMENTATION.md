# 🎉 IMPLEMENTACIÓN DE ANSIBLE COMPLETADA

## ✅ Cambios Realizados

La configuración ahora usa **Ansible** en lugar de scripts bash para:
- ✅ Mayor flexibilidad y reusabilidad
- ✅ Configuración declarativa e idempotente
- ✅ Mejor manejo de errores y rollback
- ✅ Templates dinámicos con Jinja2
- ✅ Separación clara entre infraestructura (Terraform) y configuración (Ansible)

## 📦 Estructura Ansible Creada

```
ansible/
├── ansible.cfg                # Configuración de Ansible
├── inventory.ini              # Inventario de hosts
├── generate_inventory.py      # Script para generar inventario automáticamente
├── site.yml                   # Playbook principal (ejecuta todo)
├── playbook-bastion.yml       # Playbook específico del bastion
├── playbook-webservers.yml    # Playbook específico de web servers
├── templates/
│   └── index.html.j2          # Template HTML con Jinja2
└── README.md                  # Documentación completa
```

## 🔧 Playbooks Creados

### 1. playbook-bastion.yml
Configura el Bastion Host con:
- Actualización del sistema
- Instalación de herramientas (vim, wget, curl, htop, tmux, etc.)
- Configuración de SSH (ClientAliveInterval, etc.)
- Configuración de firewall
- Mensaje de bienvenida personalizado (MOTD)
- Directorio de logs

### 2. playbook-webservers.yml
Configura los Web Servers con:
- Actualización del sistema
- Instalación y configuración de Nginx
- Configuración de firewall (HTTP y SSH)
- Configuración de SELinux
- Página web personalizada con template Jinja2
- Verificación de servicio

### 3. site.yml
Playbook maestro que ejecuta ambos en secuencia

## 📝 Template HTML con Jinja2

El archivo `templates/index.html.j2` genera dinámicamente una página web que muestra:
- Número de servidor identificado automáticamente
- Hostname
- IP privada
- Sistema operativo y kernel
- Arquitectura y CPUs
- Memoria RAM y uptime
- Instance metadata de OCI (ID, region, AD, shape)
- Diseño moderno con CSS responsive

## 🚀 Flujo de Despliegue

```
1. Terraform apply
   └─> Crea infraestructura (VCN, instancias, LB)
   └─> Instancias con solo SSH configurado

2. python3 generate_inventory.py
   └─> Lee terraform outputs
   └─> Genera inventory.ini automáticamente

3. ansible all -m ping
   └─> Verifica conectividad
   └─> Bastion: conexión directa
   └─> Web servers: conexión a través del bastion (ProxyCommand)

4. ansible-playbook site.yml
   └─> Ejecuta playbook-bastion.yml
   │   └─> Configura bastion completamente
   └─> Ejecuta playbook-webservers.yml
       └─> Instala Nginx
       └─> Genera página web desde template
       └─> Configura firewall y SELinux
```

## 🎯 Ventajas de Usar Ansible

### vs Scripts Bash con user_data:

| Característica | Scripts Bash | Ansible |
|----------------|--------------|---------|
| **Reusabilidad** | Baja | Alta |
| **Idempotencia** | Manual | Automática |
| **Manejo de errores** | Básico | Avanzado |
| **Templates dinámicos** | Difícil | Fácil (Jinja2) |
| **Re-ejecución** | Compleja | Simple |
| **Testing** | Limitado | Completo |
| **Rollback** | Manual | Automático |
| **Documentación** | Código | Declarativo |
| **Módulos** | No | 3000+ |
| **Dry-run** | No | Sí (--check) |

### Beneficios Clave:

✅ **Idempotente**: Puedes ejecutar los playbooks múltiples veces sin efectos secundarios
✅ **Declarativo**: Describes el estado deseado, no los pasos
✅ **Verificación**: Ansible verifica automáticamente que todo esté correcto
✅ **Tags**: Ejecuta solo partes específicas (`--tags nginx`)
✅ **Variables**: Fácil personalización sin modificar código
✅ **Handlers**: Reinicia servicios solo si hay cambios
✅ **Facts**: Información automática del sistema
✅ **Templates**: Generación dinámica de archivos con Jinja2

## 📚 Comandos Principales

```bash
# Generar inventario
cd ansible
python3 generate_inventory.py

# Verificar conectividad
ansible all -m ping

# Ejecutar todo
ansible-playbook site.yml

# Solo bastion
ansible-playbook site.yml --tags bastion

# Solo web servers
ansible-playbook site.yml --tags webservers

# Solo actualizar página web
ansible-playbook playbook-webservers.yml --tags webpage

# Dry-run (no hace cambios)
ansible-playbook site.yml --check

# Ver tareas sin ejecutar
ansible-playbook site.yml --list-tasks

# Ejecutar con verbosidad
ansible-playbook site.yml -vvv
```

## 🔄 Re-configuración

Si necesitas cambiar la configuración:

1. **Edita el playbook correspondiente**
2. **Re-ejecuta**: `ansible-playbook site.yml`
3. Ansible aplica solo los cambios necesarios (idempotencia)

Ejemplo: Cambiar el puerto de Nginx
```yaml
# Editar playbook-webservers.yml
vars:
  nginx_port: 8080  # Cambia de 80 a 8080

# Re-ejecutar
ansible-playbook playbook-webservers.yml
```

## 🎨 Personalización del Template

El template `index.html.j2` usa variables de Ansible (facts):

```jinja2
{{ ansible_hostname }}              # Nombre del host
{{ ansible_default_ipv4.address }}  # IP privada
{{ ansible_distribution }}          # Oracle Linux
{{ ansible_processor_vcpus }}       # Número de CPUs
{{ ansible_memtotal_mb }}           # RAM en MB
```

Puedes añadir más información editando el template.

## 🔐 Configuración SSH

El inventario usa ProxyCommand para acceder a los web servers:

```ini
[webservers:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q opc@<BASTION_IP>"'
```

Esto permite a Ansible:
- Conectarse al bastion primero
- Luego saltar a los web servers
- Todo de forma transparente

## 📊 Features Implementadas

- [x] Ansible configuration file (ansible.cfg)
- [x] Dynamic inventory generation script
- [x] Bastion host playbook
- [x] Web servers playbook
- [x] Main site playbook
- [x] Jinja2 template for web page
- [x] Modular and reusable playbooks
- [x] Tags for selective execution
- [x] Handlers for service management
- [x] SELinux configuration
- [x] Firewall configuration
- [x] Package installation
- [x] Service management
- [x] File templating
- [x] Verification tasks
- [x] Comprehensive documentation

## 🎓 Próximos Pasos Opcionales

Si quieres mejorar aún más la configuración:

1. **Ansible Roles**: Organizar en roles reutilizables
2. **Ansible Vault**: Encriptar variables sensibles
3. **Dynamic Inventory**: Integrar con OCI API
4. **Ansible Tower/AWX**: UI web para gestión
5. **Testing**: Molecule para testing de roles
6. **CI/CD**: Integrar con GitHub Actions/GitLab CI

## 📖 Recursos

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Jinja2 Templates](https://jinja.palletsprojects.com/)
- [`ansible/README.md`](ansible/README.md ) - Guía completa local

---

**✨ Tu infraestructura ahora está gestionada con Terraform + Ansible - ¡Las mejores herramientas de IaC y Configuration Management!**
