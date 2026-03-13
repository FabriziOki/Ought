import QtQuick
import Quickshell.Services.UPower
import "../../components"

BarBlock {
    id: root

    property string iconPath: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/panel/24/"
    property var battery: UPower.devices.values[0]
    property string p: "-profile-" + PowerProfile.toString(PowerProfiles.profile).toLowerCase().replace("powersaver", "powersave")
    property string s: battery.state === UPowerDeviceState.Charging ? "-charging" : ""

    content: Row {
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter

        Image {
            width: 29; height: 29
            anchors.verticalCenter: parent.verticalCenter
            sourceSize: Qt.size(128, 128)
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: {
                if (root.battery.percentage * 100 > 90) return `file://${root.iconPath}battery-100${root.s}${root.p}.svg`
                if (root.battery.percentage * 100 > 80) return `file://${root.iconPath}battery-090${root.s}${root.p}.svg`
                if (root.battery.percentage * 100 > 70) return `file://${root.iconPath}battery-080${root.s}${root.p}.svg`
                if (root.battery.percentage * 100 > 60) return `file://${root.iconPath}battery-070${root.s}${root.p}.svg`
                if (root.battery.percentage * 100 > 50) return `file://${root.iconPath}battery-060${root.s}${root.p}.svg`
                if (root.battery.percentage * 100 > 40) return `file://${root.iconPath}battery-050${root.s}${root.p}.svg`
                if (root.battery.percentage * 100 > 30) return `file://${root.iconPath}battery-040${root.s}${root.p}.svg`
                if (root.battery.percentage * 100 > 20) return `file://${root.iconPath}battery-030${root.s}${root.p}.svg`
                if (root.battery.percentage * 100 > 10) return `file://${root.iconPath}battery-020${root.s}${root.p}.svg`
                if (root.battery.percentage * 100 > 5)  return `file://${root.iconPath}battery-010${root.s}${root.p}.svg`
                return `file://${root.iconPath}battery-000${root.s}${root.p}.svg`
            }
        }

        BarText {
            symbolText: ((root.battery.percentage * 100).toFixed(0)).toString() + "%"
            anchors.verticalCenter: parent.verticalCenter
            color: "#ebdbb2"
        }
    }
}
