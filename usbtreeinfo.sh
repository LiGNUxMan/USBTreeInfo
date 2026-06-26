#!/bin/bash
#
# USBInfoSpeedTree Version 7.6.20260624a
#
# Autor: Axel O'BRIEN (LiGNUxMan) axelobrien@gmail.com
#
# Colaboradores: Antigravity (Google) · Claude (Anthropic)
#

# --- Configuración de Colores ---
RESET="\e[0m"
# Versiones USB
USB1="\e[97m"; USB2="\e[90m"; USB3="\e[34m"; USB31="\e[32m"; USB32="\e[35m"; USB4="\e[31m"
# Consumo (Axel Premium Style)
PWR_ROOT="\e[1;31m"; PWR_HUB="\e[1;33m"; PWR_DEV="\e[0;32m" # Verde normal (no negrita) para dispositivos

read_sys() {
    [[ -f "/sys/bus/usb/devices/$1/$2" ]] && cat "/sys/bus/usb/devices/$1/$2" | xargs || echo ""
}

# 0. Base de datos de nombres desde lsusb (para mejores nombres)
declare -A LSUSB_NAMES
while read -r line; do
    bus=$((10#$(echo "$line" | awk '{print $2}')))
    dev=$((10#$(echo "$line" | awk '{print $4}' | tr -d :)))
    # El nombre empieza después del ID xxxx:xxxx
    name=$(echo "$line" | cut -d: -f3- | sed 's/^[0-9a-fA-F]\{4\} //')
    LSUSB_NAMES["${bus}_${dev}"]="$name"
done < <(lsusb)

# 1. Base de Datos de Dispositivos (Usando carpetas de /sys)
declare -A VIDS PIDS SPEEDS DEVNOMS VERSIONS NAMES OWN_PWR TOTAL_PWR CHILDREN
declare -a ROOTS
BASE="/sys/bus/usb/devices/"

for dev in $(ls "$BASE" | grep -E '^(usb[0-9]+|[0-9]+-[0-9]+(\.[0-9]+)*)$'); do
    VIDS["$dev"]=$(read_sys "$dev" "idVendor")
    PIDS["$dev"]=$(read_sys "$dev" "idProduct")
    SPEEDS["$dev"]=$(read_sys "$dev" "speed")
    DEVNOMS["$dev"]=$(read_sys "$dev" "devnum")
    VERSIONS["$dev"]=$(read_sys "$dev" "version")
    
    # Detección de Bus para el mapeo de lsusb
    if [[ "$dev" == usb* ]]; then
        c_bus=${dev#usb}
    else
        c_bus=${dev%%-*}
    fi
    c_dev=${DEVNOMS["$dev"]}
    
    # Nombre (Prioridad lsusb)
    ls_name="${LSUSB_NAMES["${c_bus}_${c_dev}"]}"
    if [[ -n "$ls_name" ]]; then
        NAMES["$dev"]="$ls_name"
    elif [[ "${VIDS["$dev"]}" == "1d6b" ]]; then
        NAMES["$dev"]="Linux Foundation ${VERSIONS["$dev"]} root hub"
    else
        m=$(read_sys "$dev" "manufacturer")
        p=$(read_sys "$dev" "product")
        NAMES["$dev"]=$(echo "$m $p" | xargs)
        [[ -z "${NAMES["$dev"]}" ]] && NAMES["$dev"]="Unknown Device"
    fi
    
    # Consumo propio
    pwr=$(read_sys "$dev" "bMaxPower")
    OWN_PWR["$dev"]=$(echo "$pwr" | grep -oE '[0-9]+' || echo "0")
    
    # Árbol jerárquico por nombre de carpeta
    if [[ "$dev" == usb* ]]; then
        ROOTS+=("$dev")
    else
        if [[ "$dev" == *.* ]]; then parent="${dev%.*}"; else parent="usb${dev%-*}"; fi
        CHILDREN["$parent"]+="$dev "
    fi
done

# 2. Sumatoria Recursiva (Sin subshells para evitar pérdida de datos en arrays)
RET_PWR=0
calc_total_pwr() {
    local node=$1
    local sum=0
    
    # Procesamos hijos recursivamente
    for child in ${CHILDREN["$node"]}; do
        calc_total_pwr "$child"
        sum=$((sum + RET_PWR))
    done
    
    if [[ "${VIDS["$node"]}" == "1d6b" ]]; then
        TOTAL_PWR["$node"]=$sum
    else
        pwr_val=${OWN_PWR["$node"]:-0}
        TOTAL_PWR["$node"]=$(( sum + pwr_val ))
    fi
    RET_PWR=${TOTAL_PWR["$node"]}
}

for r in "${ROOTS[@]}"; do calc_total_pwr "$r"; done

# 3. Renderizado con lógica de Axel
render() {
    local node=$1
    local level=$2
    local total=${TOTAL_PWR["$node"]:-0}
    local spd=${SPEEDS["$node"]:-0}
    
    # Indentación
    local indent=""; for ((i=0; i<level; i++)); do indent+="    "; done
    local prefix=$([[ $level -eq 0 ]] && echo "/:  " || echo "|__ ")
    
    # Color por velocidad (Igual que en Python)
    local v_color="$USB1"; local v_lab="USB 1.1 (Low Speed)"
    if [[ $spd -le 12 ]]; then :
    elif [[ $spd -le 480 ]]; then v_color="$USB2"; v_lab="USB 2.0 (High Speed)"
    elif [[ $spd -le 5000 ]]; then v_color="$USB3"; v_lab="USB 3.x Gen1 (SuperSpeed)"
    elif [[ $spd -le 10000 ]]; then v_color="$USB31"; v_lab="USB 3.x Gen2 (SuperSpeed+)"
    elif [[ $spd -le 20000 ]]; then v_color="$USB32"; v_lab="USB 3.2 Gen2x2 (SuperSpeed++)"
    else v_color="$USB4"; v_lab="USB 4.0 / Thunderbolt"; fi
    
    # Color por tipo (Energía)
    local p_color=""
    local p_val=0
    if [[ $level -eq 0 ]]; then
        p_color="$PWR_ROOT"; p_val=$total
    elif [[ -n "${CHILDREN["$node"]}" ]]; then
        p_color="$PWR_HUB"; p_val=$total
    else
        p_color="$PWR_DEV"; p_val=${OWN_PWR["$node"]}
    fi
    
    local p_tag=""
    [[ $p_val -gt 0 ]] && p_tag=" ${p_color}[${p_val}mA]${RESET}"
    
    echo -e "${indent}${prefix}${v_color}${spd}M - ${v_lab}${RESET} - Dev $(printf "%03d" "${DEVNOMS["$node"]}") - ID ${VIDS["$node"]}:${PIDS["$node"]} - ${NAMES["$node"]}${p_tag}"
    
    # Ordenar y procesar hijos
    local sorted_children=$(for c in ${CHILDREN["$node"]}; do echo "${DEVNOMS["$c"]} $c"; done | sort -n | awk '{print $2}')
    for child in $sorted_children; do render "$child" $((level + 1)); done
}

# Inicio
for r in $(echo "${ROOTS[@]}" | tr ' ' '\n' | sort); do render "$r" 0; done
