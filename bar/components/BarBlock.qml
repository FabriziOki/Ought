import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root
  property int leftPadding: 5
  property int rightPadding: 5

  // 2. Use the properties to calculate the width
  Layout.preferredWidth: contentContainer.implicitWidth + leftPadding + rightPadding
  Layout.preferredHeight: 30
  Layout.alignment: Qt.AlignVCenter
  anchors.verticalCenter: parent.verticalCenter
  radius: 5

  property Item content
  property Item mouseArea: mouseArea

  property string text
  property bool dim: false
  property bool underline: false
  property var onClicked: function() {}
  property var onHoveredChanged: function() {}

  property string hoveredBgColor: "#1b1918"

  // Background color
  color: {
    if (mouseArea.containsMouse)
      return hoveredBgColor;
    return "transparent";
  }

  states: [
    State {
      when: mouseArea.containsMouse
      PropertyChanges {
        target: root
      }
    }
  ]

  Behavior on color {
    ColorAnimation {
      duration: 200
      easing.type: Easing.OutQuad
    }
  }

  Item {
    // Contents of the bar block
    id: contentContainer
    implicitWidth:  content.implicitWidth
    implicitHeight: content.implicitHeight
    anchors.centerIn: parent
    children: content
  }

  MouseArea {
    id: mouseArea
    anchors.fill: root
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    onClicked: root.onClicked()
    onContainsMouseChanged: root.onHoveredChanged()
    cursorShape: Qt.PointingHandCursor
  }

   Rectangle {
    id: wsLine
    width: parent.width
    height: 2
    radius: 50

    color: {
      if (parent.underline)
        return "#928374";
      return "transparent";
    }
    anchors.bottom: parent.bottom
  }
}

