#!/bin/bash

# Nombre: admin_sistema.sh
# Descripción: Herramienta de administración del sistema con múltiples funciones

# Colores para la salida
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
NC='\033[0m' # Sin Color

# Función para mostrar el uso del script
mostrar_ayuda() {
    echo -e "${AZUL}Uso: $0 [opción]${NC}"
    echo "Opciones disponibles:"
    echo "  -m, --monitor     : Monitorizar recursos del sistema"
    echo "  -b, --backup      : Realizar backup de directorios importantes"
    echo "  -u, --usuarios    : Gestionar usuarios"
    echo "  -s, --servicios   : Gestionar servicios"
    echo "  -l, --logs        : Analizar logs del sistema"
    echo "  -h, --help        : Mostrar esta ayuda"
}

# Función para monitorizar recursos
monitorizar_recursos() {
    echo -e "${VERDE}=== Monitorizando recursos del sistema ===${NC}"
    
    while true; do
        clear
        echo -e "${AMARILLO}Fecha y hora: $(date)${NC}"
        echo ""
        
        echo -e "${AZUL}Uso de CPU:${NC}"
        top -bn1 | head -15
        
        echo -e "\n${AZUL}Uso de Memoria:${NC}"
        free -h
        
        echo -e "\n${AZUL}Espacio en Disco:${NC}"
        df -h
        
        echo -e "\n${AZUL}Carga del Sistema:${NC}"
        uptime
        
        echo -e "\nPresiona Ctrl+C para salir..."
        sleep 5
    done
}

# Función para realizar backup
realizar_backup() {
    echo -e "${VERDE}=== Realizando backup ===${NC}"
    
    # Directorio de backup
    BACKUP_DIR="/backup/$(date +%Y%m%d)"
    
    # Crear directorio de backup si no existe
    mkdir -p $BACKUP_DIR
    
    # Lista de directorios a respaldar
    DIRS_TO_BACKUP=("/etc" "/home" "/var/log")
    
    for dir in "${DIRS_TO_BACKUP[@]}"; do
        echo -e "${AMARILLO}Respaldando $dir...${NC}"
        tar -czf "$BACKUP_DIR/$(basename $dir).tar.gz" $dir 2>/dev/null || {
            echo -e "${ROJO}Error al respaldar $dir${NC}"
            continue
        }
    done
    
    echo -e "${VERDE}Backup completado en $BACKUP_DIR${NC}"
}

# Función para gestionar usuarios
gestionar_usuarios() {
    echo -e "${VERDE}=== Gestión de Usuarios ===${NC}"
    echo "1. Listar usuarios"
    echo "2. Crear nuevo usuario"
    echo "3. Eliminar usuario"
    echo "4. Modificar usuario"
    
    read -p "Seleccione una opción: " opcion
    
    case $opcion in
        1)
            echo -e "${AZUL}Usuarios del sistema:${NC}"
            cut -d: -f1,3 /etc/passwd | grep -v "^#"
            ;;
        2)
            read -p "Nombre del nuevo usuario: " nuevo_usuario
            useradd -m $nuevo_usuario && \
            echo -e "${VERDE}Usuario $nuevo_usuario creado exitosamente${NC}" || \
            echo -e "${ROJO}Error al crear usuario${NC}"
            ;;
        3)
            read -p "Usuario a eliminar: " usuario_eliminar
            userdel -r $usuario_eliminar && \
            echo -e "${VERDE}Usuario $usuario_eliminar eliminado exitosamente${NC}" || \
            echo -e "${ROJO}Error al eliminar usuario${NC}"
            ;;
        4)
            read -p "Usuario a modificar: " usuario_modificar
            usermod -aG sudo $usuario_modificar && \
            echo -e "${VERDE}Usuario $usuario_modificar modificado exitosamente${NC}" || \
            echo -e "${ROJO}Error al modificar usuario${NC}"
            ;;
        *)
            echo -e "${ROJO}Opción inválida${NC}"
            ;;
    esac
}

# Función para gestionar servicios
gestionar_servicios() {
    echo -e "${VERDE}=== Gestión de Servicios ===${NC}"
    echo "1. Listar servicios activos"
    echo "2. Iniciar servicio"
    echo "3. Detener servicio"
    echo "4. Reiniciar servicio"
    
    read -p "Seleccione una opción: " opcion
    
    case $opcion in
        1)
            systemctl list-units --type=service --state=running
            ;;
        2)
            read -p "Nombre del servicio a iniciar: " servicio
            systemctl start $servicio && \
            echo -e "${VERDE}Servicio $servicio iniciado${NC}" || \
            echo -e "${ROJO}Error al iniciar servicio${NC}"
            ;;
        3)
            read -p "Nombre del servicio a detener: " servicio
            systemctl stop $servicio && \
            echo -e "${VERDE}Servicio $servicio detenido${NC}" || \
            echo -e "${ROJO}Error al detener servicio${NC}"
            ;;
        4)
            read -p "Nombre del servicio a reiniciar: " servicio
            systemctl restart $servicio && \
            echo -e "${VERDE}Servicio $servicio reiniciado${NC}" || \
            echo -e "${ROJO}Error al reiniciar servicio${NC}"
            ;;
        *)
            echo -e "${ROJO}Opción inválida${NC}"
            ;;
    esac
}

# Función para analizar logs
analizar_logs() {
    echo -e "${VERDE}=== Análisis de Logs ===${NC}"
    echo "1. Ver últimos errores (journalctl)"
    echo "2. Ver intentos de login fallidos"
    echo "3. Ver accesos SSH"
    echo "4. Buscar en logs por palabra clave"
    
    read -p "Seleccione una opción: " opcion
    
    case $opcion in
        1)
            journalctl -p 3 -xb --no-pager | tail -n 50
            ;;
        2)
            grep "Failed password" /var/log/auth.log | tail -n 20
            ;;
        3)
            grep "Accepted" /var/log/auth.log | tail -n 20
            ;;
        4)
            read -p "Palabra clave a buscar: " keyword
            grep -r "$keyword" /var/log/* 2>/dev/null
            ;;
        *)
            echo -e "${ROJO}Opción inválida${NC}"
            ;;
    esac
}

# Manejo de argumentos
case "$1" in
    -m|--monitor)
        monitorizar_recursos
        ;;
    -b|--backup)
        realizar_backup
        ;;
    -u|--usuarios)
        gestionar_usuarios
        ;;
    -s|--servicios)
        gestionar_servicios
        ;;
    -l|--logs)
        analizar_logs
        ;;
    -h|--help)
        mostrar_ayuda
        ;;
    *)
        echo -e "${ROJO}Opción no válida${NC}"
        mostrar_ayuda
        exit 1
        ;;
esac
