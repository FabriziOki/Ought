pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../components"

BarBlock {
  id: root
  
  property string iconPath: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/apps/16/"
  content: RowLayout {
    spacing: 0  
    Image {
      source: `file://${root.iconPath}preferences-desktop-notification-bell.svg`
      fillMode: Image.PreserveAspectFit
      smooth: true
      sourceSize: Qt.size(20, 20)
    }
  }
}
