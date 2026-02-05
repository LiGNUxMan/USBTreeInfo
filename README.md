# USBTreeInfo (USB Tree Information) v6.1.20260204a
![License](https://img.shields.io/badge/License-GPLv3-green)
![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey?style=flat-square&logo=linux)
![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)

## 🇪🇸 Español

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
<sub>Esta captura muestra un ejemplo del script von varios hubs y dispositivos conectados.</small>

## Descripción

**USBTreeInfo** Es una herramienta ligera para Linux que visualiza la jerarquía de tus puertos USB, identificando velocidades (colores estándar de la industria) y el consumo de energía (mA) declarado por cada dispositivo.

### Características:

- 🎨 **Colores industriales:** Blanco (1.1), Gris (2.0), Azul (3.0), Verde (3.1).
- ⚡ **Monitor de energía:** Muestra los mA por dispositivo y el total por Bus.
- 🌳 **Árbol limpio:** Elimina duplicados de interfaces y oculta valores de 0mA para mayor claridad.
- 💻 **Desarrollado en la HAL9001C.**



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
