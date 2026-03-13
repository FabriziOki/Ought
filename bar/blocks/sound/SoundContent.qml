import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../../../"

Item {
  id: root
  required property Item wrapper  
  property string iconPath: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/panel/24/"
  property PwNode sink: Pipewire.defaultAudioSink
  
  implicitWidth: 300
  implicitHeight: 65
    
    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 15
      spacing: 10
      
       RowLayout {
        Layout.fillWidth: true
        spacing: 8
        
        Item {
            Layout.preferredWidth: 32 
            Layout.preferredHeight: 32
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

        Text {
          text: `${Math.round(volumeSlider.value)}%`
          color: "#ebdbb2"
          font.family: "JetBrains Mono"
          font.pixelSize: 22
        }

      Slider {
        id: volumeSlider
        Layout.fillWidth: true
        from: 0
        to: 100
        value: Pipewire.defaultAudioSink.audio.volume * 100
        onValueChanged: {
          Pipewire.defaultAudioSink.audio.volume = value / 100
        }
        
          background: Rectangle {
                  x: volumeSlider.leftPadding
                  y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                  implicitWidth: 200
                  implicitHeight: 6
                  width: volumeSlider.availableWidth
                  height: volumeSlider.hovered ? 6 : 4
                  radius: volumeSlider.hovered ? 4 : 2
                  color: Theme.get.progressBarBg

                  Behavior on height {
                    NumberAnimation {
                      duration: 300
                      easing.type: Easing.OutCubic
                    }
                  }
                  
                  Behavior on radius {
                    NumberAnimation {
                      duration: 300
                      easing.type: Easing.OutCubic
                    }
                  }

                  Rectangle {
                    width: volumeSlider.visualPosition * parent.width
                    height: parent.height
                    color: volumeSlider.pressed ? "#bdae93" : "#928374"
                    radius: 3
                  }
                }
                
          handle: Rectangle {
            id: circle
            x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
            implicitWidth:  volumeSlider.hovered ? 16 : 12
            implicitHeight: volumeSlider.hovered ? 16 : 12
            radius: volumeSlider.hovered ? 14 : 10
            color: volumeSlider.pressed ? "#bdae93" : "#928374"
            border.color: "#ebdbb2"
            border.width: 2

            Behavior on height {
              NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
              }
            }
            
            Behavior on radius {
              NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
              }
            }
          }          
        }
      }      
  }
     PwObjectTracker { 
    objects: [ Pipewire.defaultAudioSink ] 
    }
  }
