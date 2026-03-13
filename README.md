# Ought

A personal window manager shell for Hyprland built with Quickshell. It includes bar, OSD and notifications

---

## Installation

```bash
git clone https://github.com/FabriziOki/ought.git ~/.config/quickshell/ought
qs -p ~/.config/quickshell/ought  
```
> Design and tested in Hyprland. Behavior on other window managers in unknown

## Structure

```
ought/
├── bar
│   ├── blocks
│   │   ├── battery
│   │   ├── bluetooth
│   │   ├── music
│   │   ├── network
│   │   ├── notification
│   │   ├── sound
│   │   ├── CPU.qml
│   │   ├── Date.qml
│   │   ├── Datetime.qml
│   │   ├── Icon.qml
│   │   ├── Memory.qml
│   │   ├── qmldir
│   │   ├── SystemTray.qml
│   │   ├── Test.qml
│   │   ├── Time.qml
│   │   └── Workspaces.qml
│   ├── components
│   │   ├── Background.qml
│   │   ├── BarBlock.qml
│   │   ├── BarText.qml
│   │   ├── Content.qml
│   │   ├── LoadingCircle.qml
│   │   ├── NMConnecting.qml
│   │   ├── qmldir
│   │   ├── ToggleSwitch.qml
│   │   ├── WavyCircle.qml
│   │   └── Wrapper.qml
│   ├── images
│   │   ├── blue.png
│   │   ├── dark_blue.png
│   │   ├── green.png
│   │   └── orange.png
│   └── Bar.qml
├── NotificationManager.qml
├── PopupManager.qml
├── qmldir
├── README.md
├── shell.qml
└── Theme.qml
```
## Philosophy

Ought is a personal project, built to be exactly what's needed for a tiling WM workflow. If you find it useful or want to adapt it to your setup, feel free.
