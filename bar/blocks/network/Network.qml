pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Networking
import "../../components"

BarBlock {
    id: root

    property string wiredInterface: ""
    property string wiredStatus: "disconnected"

    property string iconPath: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/panel/22/"
    property var wifiDevice: {
        const devices = Networking.devices.values;
        let wifi = devices.find(w => w.type === DeviceType.Wifi)        
        if (wifi) return wifi;
        return null
    }
    property var currentWifiNetwork: {
        const wnets = wifiDevice?.networks?.values ?? [];
        let cwn = wnets.find(c => c.state === NetworkState.Connected)
        if (cwn) return cwn;
        return null;
    }

    Process {
        id: ethernetStatusProc
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE device status | grep ':ethernet' || echo 'adapter:ethernet:disconnected'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                console.log("NMCLI RAW DATA:", data);
                if (data) {
                    const parts        = data.split(":")
                    root.wiredInterface = parts[0] || ""
                    root.wiredStatus    = parts[2] || "disconnected"
                } else {
                    root.wiredStatus = "disconnected"
                }
            }
        }
    }
    
    property bool ethernetDevice:     root.wiredStatus === "connected"
    property bool ethernetConnecting: root.wiredStatus.includes("unavailable") || root.wiredStatus.includes("connecting")

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            ethernetStatusProc.running = true
        }
    }

    // ── Block content ─────────────────────────────────────────────────────────
    content: RowLayout {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Item{
            Layout.preferredWidth: 28 
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignCenter

            Image {
                anchors.fill: parent
                sourceSize: Qt.size(28, 28)
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: `file://${root.iconPath}network-wired.svg`
                opacity: (root.ethernetDevice) ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { 
                        duration: 250 
                        easing.type: Easing.InOutQuad 
                    }
                }
            }

            Image {
                anchors.fill: parent
                sourceSize: Qt.size(28, 28)
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: `file://${root.iconPath}network-wired-acquiring.svg`
                opacity: root.ethernetConnecting ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { 
                        duration: 250 
                        easing.type: Easing.InOutQuad 
                    }
                }
            }

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Item {
                    Layout.preferredWidth: 28 
                    Layout.preferredHeight: 28
                    Layout.alignment: Qt.AlignCenter


                    Image {
                        anchors.fill: parent
                        sourceSize: Qt.size(28, 28)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        source: `file://${root.iconPath}network-wireless-00.svg`
                        opacity: (!root.ethernetConnecting && !root.ethernetDevice && root.currentWifiNetwork && root.currentWifiNetwork.signalStrength * 100 < 5) ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { 
                                duration: 250 
                                easing.type: Easing.InOutQuad 
                            }
                        }
                    }

                    Image {
                        anchors.fill: parent
                        sourceSize: Qt.size(28, 28)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        source: `file://${root.iconPath}network-wireless-20.svg`
                        opacity: (!root.ethernetConnecting && !root.ethernetDevice && root.currentWifiNetwork && root.currentWifiNetwork.signalStrength * 100 >= 5 && root.currentWifiNetwork.signalStrength * 100 < 21) ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { 
                                duration: 250 
                                easing.type: Easing.InOutQuad 
                            }
                        }
                    }

                    Image {
                        anchors.fill: parent
                        sourceSize: Qt.size(28, 28)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        source: `file://${root.iconPath}network-wireless-40.svg`
                        opacity: (!root.ethernetConnecting && !root.ethernetDevice && root.currentWifiNetwork && root.currentWifiNetwork.signalStrength * 100 >= 21 && root.currentWifiNetwork.signalStrength * 100 < 41) ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { 
                                duration: 250 
                                easing.type: Easing.InOutQuad 
                            }
                        }
                    }

                    Image {
                        anchors.fill: parent
                        sourceSize: Qt.size(28, 28)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        source: `file://${root.iconPath}network-wireless-60.svg`
                        opacity: (!root.ethernetConnecting && !root.ethernetDevice && root.currentWifiNetwork && root.currentWifiNetwork.signalStrength * 100 >= 41 && root.currentWifiNetwork.signalStrength * 100 < 61) ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { 
                                duration: 250 
                                easing.type: Easing.InOutQuad 
                            }
                        }
                    }

                    Image {
                        anchors.fill: parent
                        sourceSize: Qt.size(28, 28)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        source: `file://${root.iconPath}network-wireless-80.svg`
                        opacity: (!root.ethernetConnecting && !root.ethernetDevice && root.currentWifiNetwork && root.currentWifiNetwork.signalStrength * 100 >= 61 && root.currentWifiNetwork.signalStrength * 100 < 81) ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { 
                                duration: 250 
                                easing.type: Easing.InOutQuad 
                            }
                        }
                    }

                    Image {
                        anchors.fill: parent
                        sourceSize: Qt.size(28, 28)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        source: `file://${root.iconPath}network-wireless-100.svg`
                        opacity: (!root.ethernetConnecting && !root.ethernetDevice && root.currentWifiNetwork && root.currentWifiNetwork.signalStrength * 100 >= 81) ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { 
                                duration: 250 
                                easing.type: Easing.InOutQuad 
                            }
                        }
                    }
                }
            }

            Image {
                anchors.fill: parent
                sourceSize: Qt.size(28, 28)
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: `file://${root.iconPath}network-wireless-acquiring.svg`
                opacity: (!root.ethernetDevice && !root.ethernetConnecting && root.wifiDevice?.state === DeviceConnectionState.Connecting) ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }
            }

            Image {
                anchors.fill: parent
                sourceSize: Qt.size(28, 28)
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: `file://${root.iconPath}network-wireless-offline.svg`
                opacity: (!root.ethernetDevice && !root.ethernetConnecting && root.wifiDevice?.state === DeviceConnectionState.Disconnected) ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }
            }

            Image {
                anchors.fill: parent
                sourceSize: Qt.size(28, 28)
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: `file://${root.iconPath}state-offline.svg`
                opacity: (!root.ethernetDevice && !root.ethernetConnecting && root.wifiDevice?.state === DeviceConnectionState.Unknown) ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }
            }
        }
    }
}
