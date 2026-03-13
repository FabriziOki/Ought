import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "../../"
import "../components"

RowLayout {
  spacing: 0
  property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
  anchors.verticalCenter: parent.verticalCenter

  property string iconPath: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/apps/scalable/"
  property string iconPath2: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/apps/48/"

  // Add Chinese number mapping
  property var chineseNumbers: {
    "1": "一", "2": "二", "3": "三", "4": "四", "5": "五",
    "6": "六", "7": "七", "8": "八", "9": "九", "10": "十"
  }

  Repeater {
    model: ScriptModel {
      values: {
        var seenEmpty = false
        return [...Hyprland.workspaces.values]
          .filter((ws) => {
            if (ws.monitor !== monitor || ws.name.includes("special"))
              return false

            // There is a flickering that can happen when switching from one
            // empty workspace to another where both empty workspaces are shown
            // on the bar at the same time.  This ensures that only the first
            // empty workspace is shown.
            const isNumeric = /^\d+$/.test(ws.name);
            if (!isNumeric)
              return true;
            if (!seenEmpty) {
              seenEmpty = true
              return true
            }
            return false;
          })
          // Sort workspaces by id
          .sort((a, b) => a.id - b.id)
      }
    }

    BarBlock {
      property HyprlandWorkspace ws: modelData
      property bool isActive: Hyprland.focusedMonitor?.activeWorkspace?.id === ws.id
      property bool isOpen: monitor.activeWorkspace?.id === ws.id
      property bool hasClients: ws.name.length > 2

      dim: true
      radius: 5
      gradient: isActive || isOpen ? Theme.get.buttonActiveGradient : Theme.get.buttonInactiveGradientV

      Behavior on Layout.preferredWidth {
        NumberAnimation {
          duration: 200
          easing.type: Easing.OutQuad
        }
      }
      Layout.preferredWidth: content.width + 20
      anchors.verticalCenter: parent.verticalCenter

      Rectangle {
        visible: !isActive && !isOpen
        gradient: Theme.get.buttonInactiveGradientH
        implicitWidth: parent.width 
        implicitHeight: parent.height
        radius: parent.radius
        z:-1
      }

      Rectangle {
        visible: Theme.get.buttonBorderShadow
        implicitWidth: parent.width - 1
        implicitHeight: parent.height - 1
        radius: parent.radius
        color: "transparent" // Transparent fill
        border.color: parent.isActive || parent.isOpen ? "transparent" : "black" // Inner border color
        border.width: 1 // Inner border width

        x: 1
        y: 1
        z: -1
      }

      onClicked: function() {
        Hyprland.dispatch(`workspace ${ws.id}`);
      }

      content: RowLayout {
        spacing: 0
        anchors.centerIn: parent

        Repeater {
          id: therepeater
          model: ScriptModel {
            values: getChunks(ws.name)
          }

          delegate: Item {
            property bool showText: modelData.type === "text" && modelData.value.length > 0
            property bool showIcon: modelData.type === "icon"
            property int symbolSize: isActive && isOpen ? 28 : 20
            Behavior on symbolSize {
                NumberAnimation {
                    duration: 50
                    easing.type: Easing.OutQuad
                }
            }
            property int spacerSize: 4

            implicitWidth:  {
              if (showText)
                return thetext.implicitWidth
              if (showIcon)
                return symbolSize
              return spacerSize;
            }
            implicitHeight:  {
              if (showText)
                return thetext.implicitHeight
              if (showIcon)
                return symbolSize
              return spacerSize;
            }
            Layout.alignment: Qt.AlignCenter

            Loader {
              id: thetext
              anchors.centerIn: parent
              active:  modelData.type === "text"
              sourceComponent: BarText {
                text: modelData.value
                dim: !isActive
                pointSize: isActive && isOpen ? 12 : 8
                Behavior on pointSize {
                    NumberAnimation { duration: 200 }
                }
              }
            }

            Loader {
              id: theicon
              anchors.centerIn: parent
              active: modelData.type === "icon"

              sourceComponent: Item {
                implicitWidth:  inside.implicitWidth
                implicitHeight: inside.implicitHeight
                IconImage {
                  id: inside
                  anchors.centerIn: parent
                  source: modelData.source
                  implicitSize: symbolSize
                  opacity: isActive && isOpen ? 1 : 0.5
                  mipmap: true
                }
                DropShadow {
                  anchors.fill: parent
                  verticalOffset: 1
                  horizontalOffset: 1
                  radius: 8.0
                  color: "#282828"
                  source: inside
                  opacity: isActive && isOpen ? 1 : 0.5
                }
                Rectangle {
                  visible: modelData.mult > 1
                  width: 10
                  height: width
                  radius: width / 2
                  color: "black"
                  opacity: 0.8
                  BarText {
                    text: modelData.mult
                    pointSize: 10 
                    dim: !isActive
                    style: Text.Outline
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  function getChunks(text) {
    let chunks = [];
    let buffer = "";  // Temporary storage for text segments

    let symbolChunkInd = {}

    let nextIsActive = false
    for (let c of text) {
      if (c === "󰀦") {
        nextIsActive = true
        continue
      }
      
      if (!(c in symbolImgMap)) {
        // Check if the character exists in the chineseNumbers map
        // If it does, use the Chinese character; otherwise use the original character
        let charToUse = (chineseNumbers[c] !== undefined) ? chineseNumbers[c] : c;
        
        buffer += charToUse;
        nextIsActive = false
        continue;
      }

      if (buffer.length > 0 && !/^\s*$/.test(buffer)) {
        chunks.push({
            type: "text",
            value: buffer,
        });
        buffer = ""; // Reset text buffer
      }

      if (!(c in symbolChunkInd)) {
        if (chunks[chunks.length - 1].type == "icon") {
          chunks.push({type: "spacer"})
        }
        symbolChunkInd[c] = chunks.length
        chunks.push({
          type: "icon",
          active: nextIsActive,
          source: `file://${iconPath}${symbolImgMap[c]}.svg`,
          mult: 1, // multiplicity; how many times this symbol was seen
        });
      } else {
        chunks[symbolChunkInd[c]].mult++
        if (nextIsActive)
          chunks[symbolChunkInd[c]].active = true;
      }
      nextIsActive = false
    }

    if (buffer.length > 0 && !/^\s*$/.test(buffer)) {
      chunks.push({ type: "text", value: buffer})
    }

    return chunks;
  }

  property var symbolImgMap: {
    "": "obsidian",
    "󰇧": "zen-browser",
    "󰿎": "stremio",
    "": "zathura",
    "": "spotify-launcher",
    "": "kitty",
    "󰚄": "helix",
    "󰇥": "yazi",
    "󰊴": "vesktop",
    "󰽉": "libreoffice-draw",
    "󰷈": "libreoffice-writer",
    "": "libreoffice-calc",
    "󰈩": "libreoffice-impress",
    "": "monero",
    "": "com.usebottles.bottles",
    "": "Zoom",
    "󰊻": "teams-for-linux",
    "󰻎": "btop",
    "": "blueman",
    "󰩍": "mintupload",
    "": "uos-downloadmanager",
    "󰄄": "obs",
    "": "accessories-image-viewer",
    "": "unityhub",
  }
}

