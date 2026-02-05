# USBTreeInfo (USB Tree Information) v6.1.20260204a
![License](https://img.shields.io/badge/License-GPLv3-green)
![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey?style=flat-square&logo=linux)
![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)

<img width="1166" height="466" alt="Captura de pantalla de 2026-02-04 22-04-51" src="https://github.com/user-attachments/assets/089c145e-602e-45fd-96a1-fcb17078f429" />

```shell
axel@hal9001c:~$ ./usbtreeinfo.sh
/:  480M - USB 2.0 (High Speed) - Dev 001 - ID 1d6b:0002 - Linux Foundation 2.0 root hub [1524mA]
    |__ 480M - USB 2.0 (High Speed) - Dev 008 - ID 2109:2813 - VIA Labs, Inc. VL813 Hub
        |__ 480M - USB 2.0 (High Speed) - Dev 009 - ID 2109:2813 - VIA Labs, Inc. VL813 Hub
            |__ 480M - USB 2.0 (High Speed) - Dev 011 - ID 18a5:0302 - Verbatim, Ltd Flash Drive [200mA]
            |__ 480M - USB 2.0 (High Speed) - Dev 010 - ID 0781:5567 - SanDisk Corp. Cruzer Blade [224mA]
        |__ 480M - USB 2.0 (High Speed) - Dev 012 - ID 05e3:0723 - Genesys Logic, Inc. GL827L SD/MMC/MS Flash Card Reader [500mA]
    |__ 480M - USB 2.0 (High Speed) - Dev 002 - ID 05c8:03ab - Cheng Uei Precision Industry Co., Ltd (Foxlink) HP Wide Vision HD Camera [500mA]
    |__ 12M - USB 1.1 (Low Speed) - Dev 003 - ID 8087:0aa7 - Intel Corp. Wireless-AC 3168 Bluetooth [100mA]
/:  5000M - USB 3.x Gen1 (SuperSpeed) - Dev 001 - ID 1d6b:0003 - Linux Foundation 3.0 root hub [2552mA]
    |__ 5000M - USB 3.x Gen1 (SuperSpeed) - Dev 013 - ID 2109:0813 - VIA Labs, Inc. VL813 Hub
        |__ 5000M - USB 3.x Gen1 (SuperSpeed) - Dev 014 - ID 2109:0813 - VIA Labs, Inc. VL813 Hub
            |__ 5000M - USB 3.x Gen1 (SuperSpeed) - Dev 020 - ID 2109:0715 - VIA Labs, Inc. VL817 SATA Adaptor [896mA]
        |__ 5000M - USB 3.x Gen1 (SuperSpeed) - Dev 019 - ID 0951:1666 - Kingston Technology DataTraveler 100 G3/G4/SE9 G2/50 Kyson [504mA]
        |__ 5000M - USB 3.x Gen1 (SuperSpeed) - Dev 021 - ID 2357:0601 - TP-Link UE300 10/100/1000 LAN (ethernet mode) [256mA]
    |__ 5000M - USB 3.x Gen1 (SuperSpeed) - Dev 022 - ID 0781:5583 - SanDisk Corp. Ultra Fit [896mA]
```
<sub>🇺🇸🇬🇧 This screenshot shows an example of the script with multiple hubs and devices connected.</small>

<sub>🇪🇸 Esta captura muestra un ejemplo del script von varios hubs y dispositivos conectados.</small>

---
## 🇺🇸🇬🇧 English

### Description:

**USBTreeInfo** is a lightweight tool for Linux that visualizes the hierarchy of your USB ports, identifying speeds (industry-standard colors) and power consumption (mA) reported by each device.

### Features:

- 🌳 **Clean Tree:** Removes interface duplicates and hides 0mA values for better clarity.
- 🎨 **Industrial Colors:**
    | Color |
    |-------|
    | ⚪ White: USB 1.1 (Low Speed) |
    | ⚫ Grey: USB 2.0 (High Speed) |
    | 🔵 Blue: USB 3.0 / 3.1 Gen 1 (SuperSpeed) |
    | 🟢 Green: USB 3.1 Gen 2 (SuperSpeed+) |
    | 🟣 Magenta: USB 3.2 (Gen 2x2) |
    | 🔴 Red: USB4 / Thunderbolt |

- ⚡ ***Power Monitor:** Displays mA per device and total sum per Bus.

- ⚡ **Color Coding and Power Logic:** The electrical monitoring system visually distinguishes between partial and total consumption:

    🟡 **Yellow [mA]:** Represents the individual consumption declared by each connected device (e.g., a mouse, camera, or flash drive).

    🔴 **Red [mA]:** Reserved exclusively for Root Hubs (the bus root). This value is not a hardware report per se, but the total sum of all devices connected to that bus, dynamically calculated by the script.

    **Note:** If a bus or device has no active consumption [0mA], the value is omitted to avoid showing useless data.

### 🔍 Output Anatomy:

To understand what each line tells us, let's use this example from a connected device:

```shell
|__ 5000M - USB 3.x Gen1 (SuperSpeed) - Dev 022 - ID 0781:5583 - SanDisk Corp. Ultra Fit [896mA]
```

| Component | Description |
|-----------|-------------|
| 5000M	| Speed: Theoretical maximum transfer rate (in this case, 5 Gbps). |
| USB 3.x Gen1 (SuperSpeed)	| Protocol: USB version and industry standard classification (SuperSpeed, High Speed, etc.). |
| Dev 022 | Device Number: Assigned by the Linux kernel on the current bus. |
| ID 0781:5583 | Vendor/Product ID: Unique identifier for the manufacturer and model. |
| SanDisk Corp. Ultra Fit | Description: Manufacturer name and device model. |
| [896mA] | Power: Current consumption declared by the device. |

### Quick Installation

```bash
git clone https://github.com/LiGNUxMan/USBTreeInfo.git
cd USBTreeInfo
chmod +x usbtreeinfo.sh
```

### Usage:

```bash
./usbtreeinfo.sh
```

### Contributions
Any improvement, fix, or suggestion is welcome. Feel free to contribute to this project!

### Author
- **Axel O'BRIEN (LiGNUxMan)** - GitHub Profile
- **Google Gemini** - Development Assistance

### License
This project is distributed under the GPLv3 license. Use it, modify it, and share it freely!
- Made with 💚 and passion for Free Software.

### 🚀 Future Improvements and Features
We are looking for collaborators to keep improving USBTreeInfo. These are some ideas for future versions:

1️⃣ Add power consumption for each intermediate hub.

**If you are interested in contributing, open an issue or make a pull request! 🤝**

---
## 🇪🇸 Español

### Descripción:

**USBTreeInfo** Es una herramienta ligera para Linux que visualiza la jerarquía de tus puertos USB, identificando velocidades (colores estándar de la industria) y el consumo de energía (mA) declarado por cada dispositivo.

### Características:

- 🌳 **Árbol limpio:** Elimina duplicados de interfaces y oculta valores de 0mA para mayor claridad.
- 🎨 **Colores industriales:** 
    | Color |
    |-------|
    | ⚪ Blanco: USB 1.1 (Low Speed) |
    | ⚫ Gris: USB 2.0 (High Speed) |
    | 🔵 Azul: USB 3.0 / 3.1 Gen 1 (SuperSpeed) |
    | 🟢 Verde: USB 3.1 Gen 2 (SuperSpeed+) |
    | 🟣 Magenta: USB 3.2 (Gen 2x2) |
    | 🔴 Rojo: USB4 / Thunderbolt |
  
- ⚡ **Monitor de energía:** Muestra los mA por dispositivo y el total por Bus.
- ⚡ **Código de Colores y Lógica de Energía:**
El sistema de monitoreo eléctrico diferencia visualmente entre consumos parciales y totales:

    🟡 **Amarillo [mA]:** Representa el consumo individual declarado por cada dispositivo conectado (ej: un mouse, una cámara o un pendrive).

    🔴 **Rojo [mA]:** Se reserva exclusivamente para los Root Hubs (la raíz del bus). Este valor no es un reporte del hardware en sí, sino la suma total de todos los dispositivos conectados a ese bus, calculada dinámicamente por el script.

    **Nota:** Si un bus o dispositivo no tiene consumo activo [0mA], el valor se omite para no mostrar datos inutiles.

### 🔍 Anatomía de la salida:

Para entender qué nos dice cada línea, usemos este ejemplo de un dispositivo conectado:

```shell
|__ 5000M - USB 3.x Gen1 (SuperSpeed) - Dev 022 - ID 0781:5583 - SanDisk Corp. Ultra Fit [896mA]
```

| Componente | Descripción  |
|------------|--------------|
| 5000M                     | Velocidad: Transferencia máxima teórica (en este caso, 5 Gbps).
| USB 3.x Gen1 (SuperSpeed) | Protocolo: Version del USB y clasificación estándar de la industria (SuperSpeed, High Speed, etc.).
| Dev 022                   | Número de Dispositivo: Asignado por el kernel Linux en el bus actual.
| ID 0781:5583              | Vendor/Product ID: Identificador único del fabricante y el modelo.
| SanDisk Corp. Ultra Fit   | Descripción: Nombre del fabricante y modelo del dispositivo.
| [896mA]                   | Energía: Consumo de corriente declarado por el dispositivo.

### Instalación rápida

```bash
git clone https://github.com/LiGNUxMan/USBTreeInfo.git
cd USBTreeInfo
chmod +x usbtreeinfo.sh
```

### Uso:

```bash
./usbtreeinfo.sh
```

### Contribuciones
Cualquier mejora, corrección o sugerencia es bienvenida. ¡Suma tu aporte a este proyecto!

### Autor
- **Axel O'BRIEN (LiGNUxMan)** - [GitHub Profile](https://github.com/LiGNUxMan/)
- **Google Gemini** - Asistencia en desarrollo

### Licencia
Este proyecto se distribuye bajo la licencia **GPLv3**. ¡Úsalo, modifícalo y compártelo libremente!
- Hecho con 💚 y pasión por el software libre.

### 🚀 Mejoras y funcionalidades futuras
Estamos buscando colaboradores para seguir mejorando USBTreeInfo. Estas son algunas ideas para futuras versiones:

1️⃣ Agregar el consumo de cada hub inermedio.

**Si te interesa contribuir, ¡abre un issue o haz un pull request! 🤝**


