#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# USBTreeInfo Python Version 2.2.2.20260624a
#
# Autor: Axel O'BRIEN (LiGNUxMan) axelobrien@gmail.com
#
# Colaboradores: Antigravity (Google) · Claude (Anthropic)
#

import os
import re
import subprocess

# --- Paleta de Colores Estricta ---
COLOR_MAP = {
    "1.1": "\033[37m",   # Blanco
    "2.0": "\033[90m",   # Gris
    "3.0": "\033[34m",   # Azul (USB 3.x Gen 1)
    "3.1": "\033[32m",   # Verde (USB 3.x Gen 2)
    "3.2": "\033[35m",   # Magenta (USB 3.2 Gen 2x2)
    "4.0": "\033[31m",   # Rojo (USB 4.0)
}

# --- Colores de Consumo (Premium Style) ---
PWR_ROOT = "\033[1;31m"  # Rojo Negrita (Root Hub)
PWR_HUB = "\033[1;33m"   # Amarillo Negrita (Hub Intermedio)
PWR_DEV = "\033[32m"     # Verde Normal (Dispositivo Final)
RESET = "\033[0m"

# --- Caché de Nombres de lsusb ---
LSUSB_NAMES = {}

def load_lsusb_names():
    """Carga los nombres amigables de lsusb en un diccionario."""
    try:
        output = subprocess.check_output(["lsusb"], stderr=subprocess.STDOUT).decode()
        for line in output.splitlines():
            # Bus 001 Device 003: ID xxxx:xxxx Name...
            parts = line.split()
            if len(parts) >= 6:
                bus = int(parts[1])
                dev = int(parts[3].strip(':'))
                # El nombre empieza después del ID xxxx:xxxx (que es parts[5])
                name = " ".join(parts[6:])
                LSUSB_NAMES[(bus, dev)] = name
    except Exception:
        pass

class USBNode:
    def __init__(self, sys_path):
        self.sys_path = sys_path
        self.dev_id = os.path.basename(sys_path)
        self.children = []
        self.level = 0
        
        # Leer atributos básicos
        self.id_vendor = self._read_attr("idVendor")
        self.id_product = self._read_attr("idProduct")
        self.speed = self._read_attr("speed")
        self.busnum = int(self._read_attr("busnum") or 0)
        self.devnum = int(self._read_attr("devnum") or 0)
        self.version = self._read_attr("version") or "2.0"
        self.b_max_power = self._read_attr("bMaxPower")
        self.b_device_class = self._read_attr("bDeviceClass")
        
        # Limpieza de versión robusta
        self.v_clean = "2.0"
        v_match = re.search(r'([0-9]+\.[0-9]+)', self.version)
        if v_match:
            ver_str = v_match.group(1)
            major, minor = ver_str.split('.')
            self.v_clean = f"{int(major)}.{int(minor)}"

        # Nombre legible (lsusb priority)
        self.friendly_name = self._get_friendly_name()
        
    def _read_attr(self, attr):
        path = os.path.join(self.sys_path, attr)
        if os.path.exists(path):
            with open(path, 'r') as f:
                return f.read().strip()
        return None

    def _get_friendly_name(self):
        # 1. lsusb cache
        if (self.busnum, self.devnum) in LSUSB_NAMES:
            return LSUSB_NAMES[(self.busnum, self.devnum)]
            
        # 2. Root Hub
        if self.id_vendor == "1d6b":
            return f"Linux Foundation {self.v_clean} root hub"
        
        # 3. Fallback: sysfs
        m = self._read_attr("manufacturer") or ""
        p = self._read_attr("product") or ""
        name = f"{m} {p}".strip()
        return name if name else "Unknown Device"

    def get_total_pwr(self):
        child_pwr = sum(child.get_total_pwr() for child in self.children)
        if self.id_vendor == "1d6b":
            return child_pwr
        
        own_pwr = 0
        if self.b_max_power:
            m = re.search(r'(\d+)', self.b_max_power)
            if m: own_pwr = int(m.group(1))
        return own_pwr + child_pwr

    def render(self, level=0):
        total = self.get_total_pwr()
        s_val = int(self.speed) if self.speed and self.speed.isdigit() else 0
        
        # Color y Etiqueta por Velocidad
        v_key, ver_lab = "2.0", f"USB {self.v_clean}"
        if s_val <= 12: v_key, ver_lab = "1.1", "USB 1.1 (Low Speed)"
        elif s_val <= 480: v_key, ver_lab = "2.0", "USB 2.0 (High Speed)"
        elif s_val <= 5000: v_key, ver_lab = "3.0", "USB 3.x Gen1 (SuperSpeed)"
        elif s_val <= 10000: v_key, ver_lab = "3.1", "USB 3.x Gen2 (SuperSpeed+)"
        elif s_val <= 20000: v_key, ver_lab = "3.2", "USB 3.2 Gen2x2 (SuperSpeed++)"
        else: v_key, ver_lab = "4.0", "USB 4.0 / Thunderbolt"
        
        v_color = COLOR_MAP.get(v_key, RESET)
        
        # Color por Energía
        p_color, p_val = PWR_DEV, total
        if level == 0:
            p_color = PWR_ROOT
        elif self.children:
            p_color = PWR_HUB
        else:
            # Dispositivo final: mostramos su propio consumo
            m = re.search(r'(\d+)', self.b_max_power or "0")
            p_val = int(m.group(1)) if m else 0

        p_tag = f" {p_color}[{p_val}mA]{RESET}" if p_val > 0 else ""
        
        indent = "    " * level
        prefix = "/:  " if level == 0 else "|__ "
        
        print(f"{indent}{prefix}{v_color}{s_val}M - {ver_lab}{RESET} - "
              f"Dev {self.devnum:03d} - ID {self.id_vendor}:{self.id_product} - {self.friendly_name}{p_tag}")
        
        for child in sorted(self.children, key=lambda x: x.devnum):
            child.render(level + 1)

def build_tree():
    base_path = "/sys/bus/usb/devices/"
    nodes = {}
    roots = []
    load_lsusb_names()
    
    for d in os.listdir(base_path):
        if re.match(r'^(usb\d+|\d+-\d+(\.\d+)*)$', d):
            nodes[d] = USBNode(os.path.join(base_path, d))
            
    for d, node in nodes.items():
        if d.startswith("usb"):
            roots.append(node)
        else:
            parent_key = d.rsplit('.', 1)[0] if "." in d else f"usb{d.split('-')[0]}"
            if parent_key in nodes:
                parent = nodes[parent_key]
                parent.children.append(node)
    return roots

if __name__ == "__main__":
    for root in sorted(build_tree(), key=lambda x: x.dev_id):
        root.render(0)
