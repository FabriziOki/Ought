import QtQuick
import QtQuick.Layouts
import "../../../"

Item {
    id: root
    required property Item wrapper
    implicitWidth:  200
    implicitHeight: 52

    Text {
        anchors.centerIn: parent
        text: "No notifications"
        color: "#928374"
        font.pixelSize: 12
    }
}
