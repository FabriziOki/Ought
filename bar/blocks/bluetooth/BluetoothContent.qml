pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Io
import "../../components"
import "../../../"

Item {
    id: root

    required property Item wrapper

    // ── Local state ───────────────────────────────────────────────────────────
    property string iconPath:  "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/panel/24/"
    property string iconPath2: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/devices/scalable/"
    property string iconPath3: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/emblems/48/"

    property var adapter: Bluetooth.defaultAdapter
    property bool btStatus: adapter?.state ?? false

    // Natively filter paired vs available devices directly from Quickshell!
    property var pairedDevices: {
        if (!adapter) return [];
        return adapter.devices.values.filter(d => d.paired);
    }

    property var newDevices: {
        if (!adapter) return [];
        return adapter.devices.values.filter(d => !d.paired);
    }

    // ── Processes ─────────────────────────────────────────────────────────────
    Process {
        id: bredrScanProc
        // Force the adapter into Classic Bluetooth mode to grab names and icons
        command: ["bluetoothctl", "--timeout", "20", "scan", "bredr"]
    }

    Process {
        id: manualPairProc
        property string targetMac: ""
        
        // Chain the commands: trust -> pair -> connect
        command: ["sh", "-c", `bluetoothctl trust ${targetMac} && bluetoothctl pair ${targetMac} && bluetoothctl connect ${targetMac}`]
    }

    implicitWidth:  300
    implicitHeight: 350

    // ── UI ────────────────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        // ── Header toggle row ─────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.get.popupItemHeight
            color: Theme.get.popupItemBgOnColor
            topLeftRadius: 15; topRightRadius: 15
            bottomLeftRadius: 15; bottomRightRadius: 15

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Image {
                    source: `file://${root.iconPath2}bluetooth.svg`
                    sourceSize: Qt.size(32, 32)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: root.btStatus ? 1 : 0.5
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }

                Item { Layout.rightMargin: 5 }

                Text {
                    text: "Bluetooth"
                    color: root.btStatus ? "#bdae93" : "#80bdae93"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 20
                    font.weight: root.btStatus ? 600 : 200
                }

                Item { Layout.fillWidth: true }

                ToggleSwitch {
                    id: blueToggle
                    checked: root.btStatus
                    // Instantly toggles the native adapter power!
                    onToggled: newState => {
                        if (root.adapter) root.adapter.enabled = newState;
                    }
                }
            }
        }

        // ── Off state ─────────────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !root.btStatus

            Text {
                anchors.centerIn: parent
                text: "Bluetooth is turned off"
                color: "#80a89984"
                font.family: "JetBrains Mono"
                font.pixelSize: 16
            }
        }

        // ── On state ──────────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.btStatus
            spacing: 5

            // Paired devices header
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 10; Layout.rightMargin: 10

                Text {
                    text: "Trusted Devices"
                    color: "#a89984"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    font.weight: 200
                }
                Image {
                    source: `file://${root.iconPath3}blueman-paired-emblem.svg`
                    sourceSize: Qt.size(20, 20)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }

            ListView {
                id: pairedList
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.maximumHeight: 130
                clip: true
                spacing: 2.5
                model: root.pairedDevices
                property string expandedAddress: ""

                delegate: Rectangle {
                    id: delegateRoot
                    required property var modelData
                    required property int index
                    readonly property bool isExpanded: pairedList.expandedAddress === modelData.address
                    width: ListView.view.width

                    height: Theme.get.popupItemHeight + (isExpanded ? dropdownMenu.implicitHeight : 0)
                    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    clip: true // Prevents the dropdown content from spilling out while animating

                    color: (delegateMouse.containsMouse || isExpanded) ? Qt.lighter(Theme.get.popupItemBgOnColor, 1.2) : Theme.get.popupItemBgOnColor
                    Behavior on color { ColorAnimation { duration: 150 } }
                    topLeftRadius:     index === 0 ? 15 : 5
                    topRightRadius:    index === 0 ? 15 : 5
                    bottomLeftRadius:  index === ListView.view.count - 1 ? 15 : 5
                    bottomRightRadius: index === ListView.view.count - 1 ? 15 : 5

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.get.popupItemHeight

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                spacing: 10

                                Image {
                                    source: `file://${root.iconPath2}${modelData.icon || 'bluetooth'}.svg`
                                    sourceSize: Qt.size(32, 32)
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    onStatusChanged: {
                                        if (status === Image.Error)
                                            source = `file://${root.iconPath2}bluetooth.svg`
                                    }
                                }

                                ColumnLayout {
                                    spacing: 0
                                    Layout.alignment: Qt.AlignVCenter

                                    Text {
                                        text: modelData.name || "Unknown Device"
                                        color: "#bdae93"
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 16
                                        elide: Text.ElideRight
                                        Layout.maximumWidth: 260
                                    }
                                    Text {
                                        // Changed from modelData.mac to modelData.address to match API
                                        text: modelData.address 
                                        color: "#80a89984"
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 12
                                    }
                                }

                                LoadingCircle {
                                    Layout.preferredWidth: 24; Layout.preferredHeight: 24
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.rightMargin: 5
                                    visible: (modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting) ? true : false
                                    running: visible
                                }

                                Image {
                                    source: `file://${root.iconPath3}checkmark.svg`
                                    sourceSize: Qt.size(24, 24)
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    opacity: (modelData.state === BluetoothDeviceState.Connected) ? 1 : 0
                                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                }

                                Item { Layout.fillWidth: true }
                            }

                    

                            // The Click Handler
                            MouseArea {
                                id: delegateMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                
                                onClicked: (mouse) => {
                                    if (mouse.button === Qt.LeftButton) {
                                        if (modelData.connected) modelData.disconnect();
                                        else modelData.connect();
                                    } else if (mouse.button === Qt.RightButton) {
                                        // TOGGLE THE ACCORDION!
                                        if (pairedList.expandedAddress === modelData.address) {
                                            pairedList.expandedAddress = ""; // Close it if it's already open
                                        } else {
                                            pairedList.expandedAddress = modelData.address; // Open this one
                                        }
                                    }
                                }
                            }
                        }

                        // ── Bottom Row: The Inline Dropdown Menu ──────────────────────
                        Item {
                            id: dropdownMenu
                            Layout.fillWidth: true
                            implicitHeight: 80 // Total height of the buttons inside (40 + 40)
                            visible: delegateRoot.height > Theme.get.popupItemHeight // Render optimization
                            
                            opacity: isExpanded ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 5
                                spacing: 2

                                // Connect / Disconnect Action
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 35
                                    color: action1Mouse.containsMouse ? "#665c54" : "transparent"
                                    radius: 4

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: modelData.connected ? "Disconnect" : "Connect"
                                        color: action1Mouse.containsMouse ? "#ebdbb2" : "#bdae93"
                                        font.family: "JetBrains Mono"
                                    }

                                    MouseArea {
                                        id: action1Mouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (modelData.connected) modelData.disconnect();
                                            else modelData.connect();
                                            pairedList.expandedAddress = ""; // Auto-close menu after action
                                        }
                                    }
                                }

                                // Forget Device Action
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 35
                                    color: action2Mouse.containsMouse ? "#665c54" : "transparent"
                                    radius: 4

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: "Forget Device"
                                        color: action2Mouse.containsMouse ? "#cc241d" : "#fb4934" // Red for danger
                                        font.family: "JetBrains Mono"
                                    }

                                    MouseArea {
                                        id: action2Mouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            modelData.forget();
                                            pairedList.expandedAddress = ""; // Auto-close menu
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Available devices header
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 10; Layout.rightMargin: 10

                Text {
                    text: "Available Devices"
                    color: "#a89984"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    font.weight: 200
                }
                Image {
                    source: `file://${root.iconPath3}emblem-added.svg`
                    sourceSize: Qt.size(20, 20)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
                Item { Layout.fillWidth: true }
                
                LoadingCircle {
                    Layout.preferredWidth: 18; Layout.preferredHeight: 18
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 5
                    visible: root.adapter?.discovering ?? false
                    running: visible
                }
                
                MouseArea {
                    Layout.preferredWidth: 24; Layout.preferredHeight: 24
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        if (root.adapter) {
                            root.newDevices.forEach(device => device.forget());
                            root.adapter.discoverable = !root.adapter.discoverable
                            root.adapter.discoverableTimeout = 30
                            bredrScanProc.running = true
                        }
                    }
                    Image {
                        source: `file://${root.iconPath3}emblem-dropbox-syncing.svg`
                        sourceSize: Qt.size(24, 24)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        opacity: parent.containsMouse ? 1 : 0.5
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2.5
                model: root.newDevices

                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: Theme.get.popupItemHeight
                    color: delegateMouse2.containsMouse ? Qt.lighter(Theme.get.popupItemBgOnColor, 1.5) : Theme.get.popupItemBgOnColor
                    Behavior on color { ColorAnimation { duration: 200 } }
                    topLeftRadius:     index === 0 ? 15 : 5
                    topRightRadius:    index === 0 ? 15 : 5
                    bottomLeftRadius:  index === ListView.view.count - 1 ? 15 : 5
                    bottomRightRadius: index === ListView.view.count - 1 ? 15 : 5

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10; anchors.rightMargin: 10
                        spacing: 10

                        Image {
                            source: `file://${root.iconPath2}${modelData.icon || 'bluetooth'}.svg`
                            sourceSize: Qt.size(32, 32)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            onStatusChanged: {
                                if (status === Image.Error)
                                    source = `file://${root.iconPath2}bluetooth.svg`
                            }
                        }

                        ColumnLayout {
                            spacing: 0
                            Layout.alignment: Qt.AlignVCenter
                            Text {
                                text: modelData.name || "Unknown Device"
                                color: "#bdae93"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 16
                                elide: Text.ElideRight
                                Layout.maximumWidth: 260
                            }
                            Text {
                                text: modelData.address 
                                color: "#80a89984"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 12
                            }
                        }

                        LoadingCircle {
                            Layout.preferredWidth: 24; Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: 5
                            visible: modelData.pairing ? true : false
                            running: visible
                        }

                        Item { Layout.fillWidth: true }
                    }

                    MouseArea {
                        id: delegateMouse2
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.adapter.pairableTimeout = 30
                            root.adapter.pairable = true
                            modelData.pair()
                            modelData.trusted = true
                        }
                    }
                }
            }
        }
    }
}
