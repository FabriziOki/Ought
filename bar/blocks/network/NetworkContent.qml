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

    // ── Icon paths ────────────────────────────────────────────────────────────
    property string iconPath:  "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/panel/22/"
    property string iconPath2: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/status/48/"
    property string iconPath3: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/emblems/48/"

    // ── Ethernet (Process — not yet in native API) ────────────────────────────
    property string wiredInterface: ""
    property string wiredStatus:    "disconnected"

    Process {
        id: ethernetStatusProc
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE device status | grep ':ethernet' || echo 'adapter:ethernet:disconnected'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    const parts         = data.split(":")
                    root.wiredInterface = parts[0] || ""
                    root.wiredStatus    = parts[2] || "disconnected"
                } else {
                    root.wiredStatus = "disconnected"
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: ethernetStatusProc.running = true
    }

    Process {
        id: wifiToggleCmd
        onExited: wifiStateChecker.running = true   // re-check state after toggling
    }


    // ── Wifi — native API ─────────────────────────────────────────────────────
    property var wifiDevice: {
        const devices = Networking.devices.values
        return devices.find(d => d.type === DeviceType.Wifi) ?? null
    }

    property var currentWifiNetwork: {
        const nets = wifiDevice?.networks?.values ?? []
        return nets.find(n => n.state === ConnectionState.Connected) ?? null
    }

    // Null-guarded connection status
    readonly property string connectionStatus: {
        if (!wifiDevice) return "unavailable"
        const s = wifiDevice.state
        if (s === ConnectionState.Connected)    return "connected"
        if (s === ConnectionState.Connecting)   return "connecting"
        if (s === ConnectionState.Disconnected) return "disconnected"
        return "unavailable"
    }

    readonly property string ssid:           currentWifiNetwork?.name ?? ""
    readonly property int    signalStrength: Math.round((currentWifiNetwork?.signalStrength ?? 0) * 100)

    property bool isWifiConnected: wifiDevice?.state === ConnectionState.Connected ?? false

    // ── Available networks — at root so onAvailableNetworksChanged fires ─────
    property var availableNetworks: {
        const nets = wifiDevice?.networks?.values ?? []
        return nets
            .filter(n => n.state !== ConnectionState.Connected)
            .sort((a, b) => b.signalStrength - a.signalStrength)
    }

    // ── Scan state ────────────────────────────────────────────────────────────
    property bool scanning: false

    function triggerScan() {
        if (!wifiDevice) return
        root.scanning = true
        wifiDevice.scannerEnabled = true
        scanTimeout.restart()
    }

    Timer {
        id: scanTimeout
        interval: 4000
        onTriggered: root.scanning = false
    }

    // Stop early if results arrive before timeout
    onAvailableNetworksChanged: {
        if (availableNetworks.length > 0) {
            root.scanning = false
            scanTimeout.stop()
        }
    }

    // Auto-scan when popup opens
    onVisibleChanged: if (visible) root.triggerScan()

    // ── Size ──────────────────────────────────────────────────────────────────
    implicitWidth:  320
    implicitHeight: 400

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
                    spacing: -10

                    // ── Top Row: "Ethernet" + Status ──
                    RowLayout {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 10

                        Text {
                            text: "Ethernet"
                            color: root.wiredStatus === "connected" ? "#bdae93" : "#80bdae93"
                            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 22
                            font.weight: root.wiredStatus === "connected" ? 600 : 200
                            Behavior on font.weight { NumberAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                        }

                        RowLayout {
                            spacing: 8
                            opacity: root.wiredStatus === "disconnected" ? 0 : 1
                            Layout.preferredWidth: root.wiredStatus === "disconnected" ? 0 : implicitWidth
                            clip: true

                            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                            Behavior on Layout.preferredWidth { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                            Text {
                                text: ""
                                color: root.wiredStatus === "connected" ? "#79740e" : "#80bdae93"
                                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
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
                                font.family: "JetBrainsMono Nerd Font"
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
                            implicitWidth: 24; implicitHeight: 24   
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: 10
                            visible: root.wiredStatus === "unavailable" || root.wiredStatus === "connecting (getting IP configuration)"
                            running: visible
                        }

                        Text {
                            text: "󱎔"
                            color: root.wiredStatus === "connected" ? "#928374" : "#80bdae93"
                            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 24
                        }

                        Text {
                            text: root.wiredInterface
                            color: root.wiredStatus === "connected" ? "#928374" : "#80bdae93"
                            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                            font.family: "JetBrainsMono Nerd Font"
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
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    font.weight: root.connectionStatus === "connected" ? 600 : 200
                }

                Item { Layout.fillWidth: true }

                LoadingCircle {
                    implicitWidth: 24; implicitHeight: 24   
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 10
                    visible: root.connectionStatus === "connecting"
                    running: visible
                }

                ToggleSwitch {
                    id: wifiToggle
                    checked: root.wifiDevice.state === ConnectionState.Connected
                    onToggled: newState => {
                        wifiToggleCmd.command = ["nmcli", "radio", "wifi", newState ? "on" : "off"]
                        wifiToggleCmd.running = true
                    }
                }
            }
        }

        Item { Layout.margins: 2.5 }

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

                Column {
                    spacing: -2.5                    

                    Text {
                        text: {
                            if (root.connectionStatus === "connected" && root.ssid !== "") return root.ssid
                            if (root.connectionStatus === "connecting") return "Connecting"
                            return "Unavailable"
                        }
                        color: root.connectionStatus === "connected" ? "#bdae93" : "#80bdae93"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 20
                        font.weight: root.connectionStatus === "connected" ? 400 : 200
                    }

                    Text {
                        text: root.connectionStatus === "connected" ? WifiSecurityType.toString(root.currentWifiNetwork.securiy) : ""
                        color: "#80a89984"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.weight: 200
                    }
                }
                Item { Layout.fillWidth: true }

                Image {
                    source: `file://${root.iconPath3}emblem-locked.svg`
                    sourceSize: Qt.size(28, 28)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: root.connectionStatus === "connected" && root.currentWifiNetwork.security ? 1 : 0
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
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.weight: 200
            }

            Item { Layout.fillWidth: true }

            MouseArea {
                implicitHeight: 24; implicitWidth: 24
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: root.triggerScan()
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
            id: networkListArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Wi-Fi radio off
            Text {
                anchors.centerIn: parent
                text: "Wi-Fi is turned off"
                color: "#80a89984"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                visible: !root.isWifiConnected
            }

            // Scanning — uses native scannerEnabled
            RowLayout {
                anchors.centerIn: parent
                spacing: 10
                visible: root.scanning

                LoadingCircle { implicitHeight: 24; implicitWidth: 24; running: parent.visible }

                Text {
                    text: "Scanning..."
                    color: "#80a89984"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                }
            }

            ListView {
                anchors.fill: parent
                clip: true
                spacing: 2.5
                model: root.availableNetworks
                visible: !root.scanning
                      && root.isWifiConnected
                      && root.availableNetworks.length > 0

                delegate: Rectangle {
                    id: netItem
                    required property var modelData
                    required property int index

                    // Hoist here so children can reference by id — avoids
                    // fragile parent.parent chains with pragma ComponentBehavior: Bound
                    readonly property int  sig:       Math.round((modelData.signalStrength ?? 0) * 100)
                    readonly property bool isSecured: (modelData.security ?? WifiSecurityType.Open) !== WifiSecurityType.Open

                    width: ListView.view.width
                    height: Theme.get.popupItemHeight
                    color: Theme.get.popupItemBgOnColor
                    topLeftRadius:     index === 0                        ? 15 : 5
                    topRightRadius:    index === 0                        ? 15 : 5
                    bottomLeftRadius:  index === ListView.view.count - 1 ? 15 : 5
                    bottomRightRadius: index === ListView.view.count - 1 ? 15 : 5

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: netItem.modelData.connectTo()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10; anchors.rightMargin: 10

                        Image {
                            source: {
                                const s = netItem.sig
                                if (s >= 81) return `file://${root.iconPath}network-wireless-100.svg`
                                if (s >= 61) return `file://${root.iconPath}network-wireless-80.svg`
                                if (s >= 41) return `file://${root.iconPath}network-wireless-60.svg`
                                if (s >= 21) return `file://${root.iconPath}network-wireless-40.svg`
                                if (s >= 5)  return `file://${root.iconPath}network-wireless-20.svg`
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
                                text: netItem.modelData.name
                                color: "#bdae93"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 16
                            }
                            Text {
                                text: netItem.isSecured ? WifiSecurityType.toString(netItem.modelData.security) : "Open"
                                color: "#80a89984"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                font.weight: 200
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Image {
                            source: netItem.isSecured
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
