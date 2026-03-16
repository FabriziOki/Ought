pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Networking
import "../../components"
import "../../../"

Item {
    id: root

    // ── Required by Content.qml ───────────────────────────────────────────────
    required property Item wrapper

    // ── Local state ───────────────────────────────────────────────────────────
    property string iconPath:  "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/panel/22/"
    property string iconPath2: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/status/48/"
    property string iconPath3: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/emblems/48/"

    property string connectionStatus: "disconnected"
    property string ssid:             ""
    property string security:         ""
    property int    signalStrength:   0
    property string wiredInterface:   ""
    property string wiredStatus:      "disconnected"

    property var _scanBuffer: []
    property var networks:    []
    property var wifiDevice: {
        const devices = Networking.devices.values;
        let wifi = devices.find(w => w.type === DeviceType.Wifi)        
        if (wifi) return wifi;
        return null
    }
    property var currentWifiNetwork: {
        const wnets = wifiDevice.networks.values;
        let cwn = wnets.find(c => c.state === NetworkState.Connected)
        if (cwn) return cwn;
        return null;
    }

    // ── Size ──────────────────────────────────────────────────────────────────
    implicitWidth:  360
    implicitHeight: 400

    // ── Processes ─────────────────────────────────────────────────────────────
    Process { id: wifiCmd }

    Process {
        id: wifiStateChecker
        command: ["nmcli", "radio", "wifi"]
        running: true
        stdout: SplitParser {
            onRead: data => wifiToggle.checked = data.trim() === "enabled"
        }
    }

    Process {
        id: wifiStatusProc
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status | grep ':wifi' | grep -v 'p2p'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    const parts        = data.split(":")
                    root.connectionStatus = parts[2] || "unavailable"
                    root.ssid             = parts[3] || ""
                } else {
                    root.connectionStatus = "disconnected"
                    root.ssid             = ""
                }
            }
        }
    }

    Process {
        id: ethernetStatusProc
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE device status | grep ':ethernet' || echo 'adapter:ethernet:disconnected'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    const parts         = data.split(":")
                    root.wiredInterface  = parts[0] || ""
                    root.wiredStatus     = parts[2] || "disconnected"
                } else {
                    root.wiredStatus = "disconnected"
                }
            }
        }
    }

    Process {
        id: wifiSignal
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL,SECURITY dev wifi | grep '*'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    const parts        = data.split(":")
                    root.signalStrength = parseInt(parts[1]) || 0
                    root.security       = parts[2] || ""
                } else {
                    root.signalStrength = 0
                }
            }
        }
    }

    Process {
        id: scanProc
        command: ["sh", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list --rescan yes"]
        running: root.wrapper.hasCurrent && root.wrapper.currentName === "network"
        onRunningChanged: { if (running) root._scanBuffer = [] }
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                const parts = data.split(":")
                const ssid  = parts[0]
                if (ssid === root.ssid) return
                if (ssid && ssid.length > 0 && !root._scanBuffer.some(n => n.ssid === ssid)) {
                    root._scanBuffer.push({ ssid, signal: parseInt(parts[1]) || 0, security: parts[2] || "" })
                    root._scanBuffer.sort((a, b) => b.signal - a.signal)
                    root.networks = root._scanBuffer.slice()
                }
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            wifiStatusProc.running     = true
            ethernetStatusProc.running = true
            wifiSignal.running         = true
            wifiStateChecker.running   = true
        }
    }

    // ── UI ────────────────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 0

        // ── Ethernet row ──────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.get.popupItemHeight * 1.125
            color: Theme.get.popupItemBgOnColor
            radius: 15

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Image {
                    source: root.wiredStatus === "connected"
                        ? `file://${root.iconPath2}nm-device-wired.svg`
                        : `file://${root.iconPath2}network-offline.svg`
                    sourceSize: Qt.size(42, 42)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: root.wiredStatus === "connected" ? 1 : 0.5
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    anchors.verticalCenter: parent.verticalCenter
                }


                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter
                    
                    spacing: -15

                    // ── Top Row: "Ethernet" + Status ──
                    RowLayout {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 10

                        Text {
                            text: "Ethernet"
                            color: root.wiredStatus === "connected" ? "#bdae93" : "#80bdae93"
                            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                            font.family: "JetBrains Mono"
                            font.pixelSize: 22
                            font.weight: root.wiredStatus === "connected" ? 600 : 200
                            Behavior on font.weight { NumberAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                        }

                        // Wrapper to animate the dot and status text horizontally
                        RowLayout {
                            spacing: 8
                            opacity: root.wiredStatus === "disconnected" ? 0 : 1
                            Layout.preferredWidth: root.wiredStatus === "disconnected" ? 0 : implicitWidth
                            clip: true // Prevents text from spilling outside while width shrinks
                            
                            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                            Behavior on Layout.preferredWidth { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                            Text {
                                text: ""
                                color: root.wiredStatus === "connected" ? "#79740e" : "#80bdae93"
                                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                                font.family: "JetBrains Mono"
                                font.pixelSize: 14
                                font.weight: root.wiredStatus === "connected" ? 600 : 200
                                Behavior on font.weight { NumberAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                            }

                            Text {
                                text: {
                                    if (root.wiredStatus === "connected") return "Connected"
                                    if (root.wiredStatus === "unavailable" || root.wiredStatus === "connecting (getting IP configuration)") return "Connecting.."
                                    return "Unavailable"
                                }
                                color: root.wiredStatus === "connected" ? "#79740e" : "#80bdae93"
                                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                                font.family: "JetBrains Mono"
                                font.pixelSize: 18
                                font.weight: 200
                            }
                        }
                    }

                    // ── Bottom Row: Interface Details ──
                    RowLayout {
                        opacity: root.wiredStatus === "disconnected" ? 0 : 1
                        
                        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        Behavior on Layout.preferredHeight { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                        LoadingCircle {
                            id: loadCirc
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: 10
                            visible: root.wiredStatus === "unavailable" || root.wiredStatus === "connecting (getting IP configuration)"
                            running: visible
                        }

                        Text {
                            text: "󱎔"
                            color: root.wiredStatus === "connected" ? "#928374" : "#80bdae93"
                            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                            font.family: "JetBrains Mono"
                            font.pixelSize: 32
                        }

                        Text {
                            text: root.wiredInterface
                            color: root.wiredStatus === "connected" ? "#928374" : "#80bdae93"
                            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                            font.family: "JetBrains Mono"
                            font.pixelSize: 18
                        }
                    }
                }
            }
        }

        Item { Layout.margins: 2.5 }

        // ── Wi-Fi toggle row ──────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.get.popupItemHeight
            color: Theme.get.popupItemBgOnColor
            topLeftRadius: 15; topRightRadius: 15
            bottomLeftRadius: 5; bottomRightRadius: 5

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Image {
                    source: root.connectionStatus === "connected"
                        ? `file://${root.iconPath2}notification-network-wireless.svg`
                        : `file://${root.iconPath2}notification-network-wireless-disconnected.svg`
                    sourceSize: Qt.size(36, 36)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: root.connectionStatus === "connected" ? 1 : 0.5
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }

                Item { Layout.rightMargin: 5 }

                Text {
                    text: "Wi-Fi"
                    color: root.connectionStatus === "connected" ? "#bdae93" : "#80bdae93"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 22
                    font.weight: root.connectionStatus === "connected" ? 600 : 200
                }

                Item { Layout.fillWidth: true }

                LoadingCircle {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 10
                    visible: wifiCmd.running || (root.connectionStatus !== "connected" && root.connectionStatus !== "unavailable")
                    running: visible
                }

                ToggleSwitch {
                    id: wifiToggle
                    onToggled: newState => {
                        wifiCmd.command = ["nmcli", "radio", "wifi", newState ? "on" : "off"]
                        wifiCmd.running = true
                    }
                }
            }
        }

        // ── Active connection row ─────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.get.popupItemHeight
            Layout.topMargin: -1.25
            color: Theme.get.popupItemBgOnColor
            bottomLeftRadius: 15; bottomRightRadius: 15
            topLeftRadius: 5; topRightRadius: 5

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Image {
                    source: {
                        if (root.connectionStatus === "connected") {
                            if (root.signalStrength >= 81) return `file://${root.iconPath}network-wireless-100.svg`
                            if (root.signalStrength >= 61) return `file://${root.iconPath}network-wireless-80.svg`
                            if (root.signalStrength >= 41) return `file://${root.iconPath}network-wireless-60.svg`
                            if (root.signalStrength >= 21) return `file://${root.iconPath}network-wireless-40.svg`
                            if (root.signalStrength >= 5)  return `file://${root.iconPath}network-wireless-20.svg`
                            return `file://${root.iconPath}network-wireless-00.svg`
                        }
                        if (root.connectionStatus === "unavailable")
                            return `file://${root.iconPath}network-wireless-offline.svg`
                        return `file://${root.iconPath}network-wireless-acquiring.svg`
                    }
                    sourceSize: Qt.size(36, 36)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Item { Layout.rightMargin: 5 }

                Text {
                    text: {
                        if (root.connectionStatus === "connected" && root.ssid !== "") return root.ssid
                        if (root.connectionStatus !== "connected" && root.connectionStatus !== "unavailable") return "Connecting"
                        return "Unavailable"
                    }
                    color: root.connectionStatus === "connected" ? "#bdae93" : "#80bdae93"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 22
                    font.weight: root.connectionStatus === "connected" ? 400 : 200
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.connectionStatus === "connected" && root.ssid !== "" ? root.security : ""
                    color: root.connectionStatus === "connected" ? "#a89984" : "#80a89984"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 18
                    font.weight: 200
                }

                Image {
                    source: `file://${root.iconPath3}emblem-locked.svg`
                    sourceSize: Qt.size(28, 28)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: root.connectionStatus === "connected" ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                Image {
                    source: `file://${root.iconPath3}blueman-trusted-emblem.svg`
                    sourceSize: Qt.size(28, 28)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: root.connectionStatus === "connected" ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
            }
        }

        Item { Layout.margins: 2.5 }

        // ── Network list header ───────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 10; Layout.rightMargin: 10
            Layout.topMargin: -5; Layout.bottomMargin: 5

            Text {
                text: "Available Networks"
                color: "#a0a89984"
                font.family: "JetBrains Mono"
                font.pixelSize: 14
                font.weight: 200
            }

            Item { Layout.fillWidth: true }

            MouseArea {
                width: 24; height: 24
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    root._scanBuffer = []
                    root.networks    = []
                    scanProc.running = true
                }
                Image {
                    source: `file://${root.iconPath3}emblem-dropbox-syncing.svg`
                    sourceSize: Qt.size(24, 24)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: parent.containsMouse ? 1 : 0.5
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
            }
        }

        // ── Network list ──────────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Wi-Fi off
            Text {
                anchors.centerIn: parent
                text: "Wi-Fi is turned off"
                color: "#80a89984"
                font.family: "JetBrains Mono"
                font.pixelSize: 16
                visible: !wifiToggle.checked
            }

            // Scanning
            RowLayout {
                anchors.centerIn: parent
                spacing: 10
                visible: wifiToggle.checked && scanProc.running && root.networks.length === 0
                LoadingCircle { width: 24; height: 24; running: parent.visible }
                Text {
                    text: "Scanning..."
                    color: "#80a89984"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 22
                }
            }

            // List
            ListView {
                anchors.fill: parent
                clip: true
                spacing: 2.5
                model: root.networks
                visible: wifiToggle.checked && root.networks.length > 0

                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: Theme.get.popupItemHeight
                    color: Theme.get.popupItemBgOnColor
                    topLeftRadius:     index === 0                        ? 15 : 5
                    topRightRadius:    index === 0                        ? 15 : 5
                    bottomLeftRadius:  index === ListView.view.count - 1 ? 15 : 5
                    bottomRightRadius: index === ListView.view.count - 1 ? 15 : 5

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10; anchors.rightMargin: 10

                        Image {
                            source: {
                                if (modelData.signal >= 81) return `file://${root.iconPath}network-wireless-100.svg`
                                if (modelData.signal >= 61) return `file://${root.iconPath}network-wireless-80.svg`
                                if (modelData.signal >= 41) return `file://${root.iconPath}network-wireless-60.svg`
                                if (modelData.signal >= 21) return `file://${root.iconPath}network-wireless-40.svg`
                                if (modelData.signal >= 5)  return `file://${root.iconPath}network-wireless-20.svg`
                                return `file://${root.iconPath}network-wireless-00.svg`
                            }
                            sourceSize: Qt.size(32, 32)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }

                        Item { Layout.rightMargin: 5 }

                        ColumnLayout {
                            spacing: 0
                            Layout.alignment: Qt.AlignVCenter
                            Text {
                                text: modelData.ssid
                                color: "#bdae93"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 16
                            }
                            Text {
                                text: root.connectionStatus === "connected" && root.ssid !== "" ? root.security : ""
                                color: root.connectionStatus === "connected" ? "#a89984" : "#80a89984"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 12
                                font.weight: 200
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Image {
                            source: modelData.security
                                ? `file://${root.iconPath3}emblem-locked.svg`
                                : `file://${root.iconPath3}emblem-unlocked.svg`
                            sourceSize: Qt.size(28, 28)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }
                    }
                }
            }
        }
    }
}
