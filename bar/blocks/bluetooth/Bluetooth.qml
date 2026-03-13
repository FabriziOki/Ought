pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Bluetooth
import "../../components"

BarBlock {
    id: root

    property var adapter: Bluetooth.defaultAdapter 
    property bool status: adapter?.state ?? false
    
    // Automatically true if ANY device in the native list is connected
    property bool isConnected: {
        if (!adapter) return false;
        return adapter.devices.values.some(device => device.connected);
    }
    
    property string iconPath: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/panel/24/"

    // ── Block content ─────────────────────────────────────────────────────────
    content: Item {
        implicitWidth: 26
        implicitHeight: 26

        // Bluetooth on
        Image {
            anchors.fill: parent
            source: `file://${root.iconPath}network-bluetooth.svg`
            opacity: root.status && !root.isConnected ? 1 : 0
            fillMode: Image.PreserveAspectFit
            smooth: true
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }

        // Bluetooth off
        Image {
            anchors.fill: parent
            source: `file://${root.iconPath}network-bluetooth-inactive.svg`
            opacity: !root.status ? 1 : 0
            fillMode: Image.PreserveAspectFit
            smooth: true
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }

        // Bluetooth connected
        Image {
            anchors.fill: parent
            source: `file://${root.iconPath}bluetooth-paired.svg`
            opacity: root.status && root.isConnected ? 1 : 0
            fillMode: Image.PreserveAspectFit
            smooth: true
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }
    }
}
