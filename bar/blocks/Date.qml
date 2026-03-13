import QtQuick
import "../components"
import "../../"

BarBlock {
  id: text
  content: BarText {
    symbolText: ` ${Datetime.date}`
  }
}

