pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../../../"

Item {
    id: root

    required property Item wrapper

    property string iconPath: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/panel/24/"
    property string iconPath2: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/status/48/"
    property string iconPath3: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/devices/scalable/"
    property string iconPath4: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/actions/24/"
    property string iconPath5: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/devices/symbolic/"
    property string iconPath6: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/status/symbolic/"
    property string iconPath7: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/apps/16/"

    property var battery: UPower.devices.values[0]
    property var isCharging: battery.state === UPowerDeviceState.Charging
    property string p: PowerProfile.toString(PowerProfiles.profile).toLowerCase().replace("powersaver", "powersave")
    property string s: isCharging ? "-charging" : ""
    property int itemHeight: 45

    implicitWidth:  320
    implicitHeight: 110

    function formatTime(s: real): string {
        const h = Math.floor(s / 3600);
        const m = Math.floor((s % 3600) / 60);
        const sec = Math.floor(s % 60);

        const paddedSec = String(sec).padStart(2, "0");

        // If there are hours, pad the minutes. Otherwise, leave minutes unpadded.
        if (h > 0) {
            const paddedMin = String(m).padStart(2, "0");
            return `${h}:${paddedMin}:${paddedSec}`;
        } 

        return `${m}:${paddedSec}`;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.itemHeight
            color: Theme.get.popupItemBgOnColor
            topLeftRadius: 15; topRightRadius: 15
            bottomLeftRadius: 15; bottomRightRadius: 15

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                Item {
                    property int isize: 32
                    Layout.preferredWidth: isize; Layout.preferredHeight: isize
                    Layout.alignment: Qt.AlignCenter

                    Image{
                        sourceSize: Qt.size(parent.isize, parent.isize)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        source: `file://${root.iconPath5}ac-adapter-symbolic.svg` 
                        opacity: (root.isCharging) ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                    }

                    Image{
                        sourceSize: Qt.size(parent.isize, parent.isize)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        source: `file://${root.iconPath6}freon-voltage-symbolic.svg` 
                        opacity: (!root.isCharging) ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                    }
                }

                Text {
                    text: (root.isCharging) ? "+" + (root.battery.changeRate.toFixed(2)).toString() + " W" : "-" + (root.battery.changeRate.toFixed(2)).toString() + " W"
                    color: (root.isCharging) ? "#b8bb26" : "#bdae93"
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.InOutBounce
                        }
                    }
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 24
                }

                Image{
                    sourceSize: Qt.size(24, 24)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    source: `file://${root.iconPath7}com.github.zren.batterytime.svg` 
                    opacity: (root.battery.state === UPowerDeviceState.Charging || root.battery.state === UPowerDeviceState.Discharging) ? 0.75 : 0
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutBounce } }
                }

                Text {
                    text: root.isCharging ? root.formatTime(root.battery.timeToFull) : root.formatTime(root.battery.timeToEmpty)
                    color: "#a89984" // Muted Gruvbox text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 20
                    font.weight: 200
                    visible: root.battery.state === UPowerDeviceState.Charging || root.battery.state === UPowerDeviceState.Discharging
                }
            }            
        }

        Rectangle {
            Layout.fillWidth: true
            // Reduced from itemHeight (64) to a slimmer pill container
            Layout.preferredHeight: 44 
            color: Theme.get.popupItemBgOnColor
            radius: 12 // Perfectly rounded edges for the outer container

            RowLayout {
                anchors.fill: parent
                anchors.margins: 4 
                spacing: 2

                ProfileButton {
                    profileId: "performance"
                    labelText: "Power"
                    iconSource: `file://${root.iconPath}battery-profile-performance.svg`
                }

                ProfileButton {
                    profileId: "balanced"
                    labelText: "Balanced"
                    iconSource: `file://${root.iconPath}battery-profile-balanced.svg`
                }

                ProfileButton {
                    profileId: "powersave"
                    labelText: "Quiet"
                    iconSource: `file://${root.iconPath}battery-profile-powersave.svg`
                }
            }            
        }
    }

    // ── Reusable Profile Button Component ─────────────────────────────────────
    component ProfileButton: Rectangle {
        id: btn
        
        property string profileId
        property string labelText
        property string iconSource
        property bool isActive: root.p === profileId

        Layout.fillWidth: true
        Layout.fillHeight: true
        // Makes the active background a perfect pill shape
        radius: height / 4 
        
        // Warm Gruvbox orange for active, subtle brown for hover, transparent for inactive
        color: isActive ? "#504238" : (hoverHandler.hovered ? "#504945" : "transparent")
        Behavior on color { ColorAnimation { duration: 200 } }

        HoverHandler { id: hoverHandler }
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: PowerProfiles.profile = btn.profileId
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 6
            
            Image {
                // Drastically reduced icon size to match the aesthetic
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                sourceSize: Qt.size(64, 64)
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: btn.iconSource
                
                opacity: btn.isActive ? 1.0 : (hoverHandler.hovered ? 0.8 : 0.5)
                Behavior on opacity { 
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } 
                }
            }
            
            Text {
                text: btn.labelText
                // Dark text on the active orange pill, standard warm text otherwise
                color: btn.isActive ? "#ebdbb2" : (hoverHandler.hovered ? "#ebdbb2" : "#bdae93")
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                font.weight: btn.isActive ? Font.Bold : Font.Normal
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }
}
