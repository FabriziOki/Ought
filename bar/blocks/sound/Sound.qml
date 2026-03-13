pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../../components"

BarBlock {
  id: root
  visible: Pipewire.ready

  property PwNode sink: Pipewire.defaultAudioSink
  property string iconPath: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/panel/24/"
  property string iconPath2: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/actions/24/"

  content: RowLayout {
    spacing: -4 
    anchors.verticalCenter: parent.verticalCenter

    Item {
        Layout.preferredWidth: 26 
        Layout.preferredHeight: 26
        Layout.alignment: Qt.AlignCenter

        Image {
            anchors.fill: parent
            source: `file://${root.iconPath}audio-volume-high.svg`
            opacity: (Math.round(root.sink.audio.volume * 100) >= 66 && Math.round(root.sink.audio.volume * 100) <= 100) ? 1 : 0

            Behavior on opacity {
                NumberAnimation { 
                    duration: 250 
                    easing.type: Easing.InOutQuad 
                }
            }
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
        Image {
            anchors.fill: parent
            source: `file://${root.iconPath}audio-volume-medium.svg`
            opacity: (Math.round(root.sink.audio.volume * 100) >= 33 && Math.round(root.sink.audio.volume * 100) <= 65) ? 1 : 0

            Behavior on opacity {
                NumberAnimation { 
                    duration: 250 
                    easing.type: Easing.InOutQuad 
                }
            }
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
        Image {
            anchors.fill: parent
            source: `file://${root.iconPath}audio-volume-low.svg`
            opacity: (Math.round(root.sink.audio.volume * 100) >= 1 && Math.round(root.sink.audio.volume * 100) <= 32) ? 1 : 0

            Behavior on opacity {
                NumberAnimation { 
                    duration: 250 
                    easing.type: Easing.InOutQuad 
                }
            }
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
        Image {
            anchors.fill: parent
            source: `file://${root.iconPath}audio-volume-off.svg`
            opacity: (Math.round(root.sink.audio.volume * 100) === 0) ? 1 : 0

            Behavior on opacity {
                NumberAnimation { 
                    duration: 250 
                    easing.type: Easing.InOutQuad 
                }
            }
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }
  }

  PwObjectTracker { objects: [ sink ] }
}
