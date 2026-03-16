import QtQuick
import "../../components"

BarBlock {
  id: root
  property string iconPath: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/panel/24/"
  content: Row {
    anchors.verticalCenter: parent.verticalCenter
    spacing: 10

    BarText {
      symbolText: ` ${Datetime.date}`
      anchors.verticalCenter: parent.verticalCenter
    }
    BarText {
      symbolText: ` ${Datetime.time}`
      anchors.verticalCenter: parent.verticalCenter
    }
    Image {
      source: root.iconPath + Weather.descFromCode(Weather.weatherCode)
      width: 26
      height: 26
      anchors.verticalCenter: parent.verticalCenter
    }
    BarText {
      symbolText: `${Math.round(Weather.tempC)}°C`
      anchors.verticalCenter: parent.verticalCenter
    }
  }
}

