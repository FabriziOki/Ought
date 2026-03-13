import QtQuick

Rectangle {
    id: toggleRoot 
    
    // Properties
    property bool checked: false
    signal toggled(bool newState)
    property color checkedColor: "#458588"
    property color uncheckedColor: "#665c54"
    property color checkedColorButton: "#ebdbb2"
    property color uncheckedColorButton: "#a89984"
    property alias pressed: switchMouseArea.pressed
    property alias hovered: switchMouseArea.containsMouse
    
    width: 50
    height: 26
    radius: height / 2
    color: checked ? checkedColor : uncheckedColor

    Behavior on color { ColorAnimation { duration: 200 } }

    // The Handle (Circle)
    Rectangle {
        id: handle
        width: parent.height - 6
        height: width
        radius: width / 2
        color: toggleRoot.checked ? toggleRoot.checkedColorButton : toggleRoot.uncheckedColorButton
        anchors.verticalCenter: parent.verticalCenter
        
        // Move calculation
        x: toggleRoot.checked ? (parent.width - width - 3) : 3
        
        Behavior on x { 
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } 
        }
    }

    // --- The Interaction Layer ---
    MouseArea {
        id: switchMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            // 1. Update the visual state
            toggleRoot.checked = !toggleRoot.checked
            // 2. Emit the signal telling the parent "The USER did this"
            toggleRoot.toggled(toggleRoot.checked)
        }
    }
}
