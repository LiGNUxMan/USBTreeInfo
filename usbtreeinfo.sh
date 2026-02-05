#!/bin/bash
# #############################################################################
#
# USBTreeInfo Version 6.1.20260205a
#
# Descripción: Visualización de árbol USB con velocidad y consumo (mA)
# Autor: Axel O'BRIEN (LiGNUxMan) <axelobrien@gmail.com> & Gemini (Google)
#
# Uso: axel@hal9001c:~$ ./usbtreeinfo.sh
#
# #############################################################################

# Colores (Esquema estándar industrial para LiGNUxMan)
RESET="\e[0m"
USB1="\e[97m"      # Blanco: 1.1
USB2="\e[90m"      # Gris: 2.0
USB3="\e[34m"      # Azul: 3.0 / 3.1 Gen 1
USB31="\e[32m"     # Verde: 3.1 Gen 2
USB32="\e[35m"     # Magenta: 3.2
USB4="\e[31m"      # Rojo: USB4 / Thunderbolt
POWER_CLR="\e[33m" # Amarillo: Consumo de dispositivos individuales
TOTAL_PWR_CLR="\e[31m" # Rojo: Consumo del hub total

get_speed_text() {
    case "$1" in
        12M)    echo -e "${USB1}12M - USB 1.1 (Low Speed)${RESET}" ;;
        480M)   echo -e "${USB2}480M - USB 2.0 (High Speed)${RESET}" ;;
        5000M)  echo -e "${USB3}5000M - USB 3.x Gen1 (SuperSpeed)${RESET}" ;;
        10000M) echo -e "${USB31}10000M - USB 3.x Gen2 (SuperSpeed+)${RESET}" ;;
        20000M) echo -e "${USB32}20000M - USB 3.2 Gen2x2${RESET}" ;;
        40000M) echo -e "${USB4}40000M - USB4 / Thunderbolt${RESET}" ;;
        *)      echo -e "${1} - USB" ;;
    esac
}

get_dev_power() {
    local pwr_path=$(grep -l "^$2$" /sys/bus/usb/devices/${1}-*/devnum 2>/dev/null | sed 's/devnum/bMaxPower/')
    [[ -f "$pwr_path" ]] && cat "$pwr_path" | tr -d 'mA ' || echo "0"
}

# 1. Cargar Base de Datos de dispositivos conectados
declare -A ID_MAP DESC_MAP PWR_MAP TOTAL_MAP
while read -r line; do
    bus=$((10#$(echo "$line" | awk '{print $2}')))
    dev=$((10#$(echo "$line" | awk '{print $4}' | tr -d :)))
    key="${bus}_${dev}"
    ID_MAP["$key"]=$(echo "$line" | awk '{print $6}')
    DESC_MAP["$key"]=$(echo "$line" | cut -d' ' -f7-)
    PWR_MAP["$key"]=$(get_dev_power "$bus" "$dev")
    # Sumar al total del bus correspondiente
    TOTAL_MAP["$bus"]=$(( TOTAL_MAP["$bus"] + PWR_MAP["$key"] ))
done < <(lsusb)

# 2. Renderizado del Árbol
current_bus=""
LAST_DEV=""

lsusb -t | while IFS= read -r line; do
    # Identificar el bus actual
    if [[ "$line" =~ Bus\ ([0-9]+) ]]; then
        current_bus=$((10#${BASH_REMATCH[1]}))
    fi

    # Identificar dispositivo
    if [[ "$line" =~ Dev\ ([0-9]+) ]]; then
        dev_num=$((10#${BASH_REMATCH[1]}))
        key="${current_bus}_${dev_num}"
        
        # Filtrar interfaces duplicadas (mismo dispositivo)
        if [[ "$key" == "$LAST_DEV" ]]; then continue; fi
        LAST_DEV="$key"

        speed_raw=$(echo "$line" | grep -oP '[0-9]+M$')
        prefix=$(echo "$line" | sed -E 's/(Bus|Port).*//')
        
        speed_fmt=$(get_speed_text "$speed_raw")
        my_id="${ID_MAP[$key]}"
        my_desc="${DESC_MAP[$key]}"
        
        # --- SECCIÓN CORREGIDA PARA FILTRAR 0mA ---
        pwr_text=""
        if [[ "$dev_num" -eq 1 ]]; then
            # Root Hub: Solo mostrar si el total acumulado es mayor a 0
            if [[ "${TOTAL_MAP["$current_bus"]}" -gt 0 ]]; then
                pwr_text=" ${TOTAL_PWR_CLR}[${TOTAL_MAP["$current_bus"]}mA]${RESET}"
            fi
        elif [[ "${PWR_MAP[$key]}" -gt 0 ]]; then
            # Dispositivo individual: Solo mostrar si es mayor a 0
            pwr_text=" ${POWER_CLR}[${PWR_MAP[$key]}mA]${RESET}"
        fi
        # ------------------------------------------

        echo -e "${prefix}${speed_fmt} - Dev $(printf "%03d" $dev_num) - ID ${my_id} - ${my_desc}${pwr_text}"
    fi
done
