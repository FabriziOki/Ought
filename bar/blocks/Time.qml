import QtQuick
import "../components"

BarBlock {
  id: text
  content: BarText {
    symbolText: ` ${Datetime.time}`
  }
}

