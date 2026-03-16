import QtQuick
import QtQuick.Layouts
import "../../../"

Item {
    id: root
    required property Item wrapper

    implicitWidth:  240
    implicitHeight: 60

    // Accent color driven by notification type
    readonly property color accentColor: {
        const t = NotificationManager.current?.type ?? ""
        if (t === "success") return "#b8bb26"
        if (t === "error")   return "#fb4934"
        if (t === "warning") return "#fabd2f"
        return "#83a598"  // info / default
    }

    RowLayout {
        anchors.fill:    parent
        anchors.leftMargin:  10
        anchors.rightMargin: 10
        spacing: 10

        // Icon
        // Text {
        //     text:                  NotificationManager.current?.icon ?? ""
        //     color:                 root.accentColor
        //     font.pixelSize:        24
        //     font.family:           "JetBrainsMono Nerd Font"
        //     Layout.alignment:      Qt.AlignVCenter
        // }

        Image {
            source: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/" + NotificationManager.current.icon
            sourceSize: Qt.size(36, 36)
            smooth: true
        }

        // Title + message
        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true

            Text {
                text:              NotificationManager.current?.title ?? ""
                color:             "#ebdbb2"
                font.pixelSize:    18
                font.weight:       Font.Medium
                elide:             Text.ElideRight
                Layout.fillWidth:  true
            }

            Text {
                text:              NotificationManager.current?.message ?? ""
                color:             "#a89984"
                font.pixelSize:    16
                elide:             Text.ElideRight
                Layout.fillWidth:  true
            }
        }
    }
}
