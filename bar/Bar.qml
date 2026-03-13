import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "blocks" as Blocks
import "blocks/music"        as Music
import "blocks/network"      as Network
import "blocks/bluetooth"    as Bluetooth
import "blocks/battery"      as Battery
import "blocks/sound"        as Sound
import "blocks/notification" as Notification
import "components"
import "../"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            property var modelData
            screen: modelData

            // ── Window setup ─────────────────────────────────────────────────
            // Full screen height so the Wrapper can render below the bar strip.
            // Only 35px is exclusive — the rest is transparent + click-through.
            height: screen.height
            color: "transparent"

            WlrLayershell.exclusiveZone: 35

            // Input mask: only the bar strip (35px) and the active popup area
            // are interactive. Everything else passes clicks through.
            mask: Region {
                // Bar strip
                Region {
                    x: 0; y: 0
                    width: bar.width; height: 35
                    intersection: Intersection.Combine
                }
                // Active popup area
                Region {
                    x: popouts.x; y: popouts.y
                    width: popouts.implicitWidth; height: popouts.implicitHeight
                    intersection: Intersection.Combine
                }
            }

            visible: true

            margins {
                top: 4
                left: 6
                right: 6
            }

            IpcHandler {
                target: "bar"
                function toggleVis(): void { bar.visible = !bar.visible }
            }

            anchors {
                top: Theme.get.onTop
                bottom: !Theme.get.onTop
                left: true
                right: true
            }

            // ── Bar strip background ─────────────────────────────────────────
            Rectangle {
                id: highlight
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 35
                gradient: Theme.get.barGradient
                bottomLeftRadius: 10
                topRightRadius: 10
                topLeftRadius: 10
                bottomRightRadius: popouts.hasCurrent && popouts.isAtRightEdge ? 0 : 10
                border.width: Theme.get.barBorderWidth
                border.color: Theme.get.barBorderColor
            }

            // ── Bar content ──────────────────────────────────────────────────
            Item {
                id: allBlocks
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 35

                // Left side
                RowLayout {
                    id: leftBlocks
                    spacing: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Blocks.Workspaces {}
                }

                // Center
                RowLayout {
                    id: centerBlocks
                    spacing: 0
                    anchors.centerIn: parent

                    Blocks.Date {}
                    Blocks.Time {}
                }

                // Right side
                RowLayout {
                    id: rightBlocks
                    spacing: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    // Each block that has a popup exposes a `name` property
                    //. so checkPopout() can identify it
                    // Blocks.Test {id: test}
                    Music.Music     { id: musicBlock }
                    Sound.Sound { id: soundBlock }
                    Bluetooth.Bluetooth { id: btBlock }
                    Network.Network { id: networkBlock }
                    Item { Layout.leftMargin: 8 }
                    Battery.Battery { id: batteryBlock }
                    Notification.Notification { id: notificationBlock; rightPadding: 10 }
                }
            }

            // ── Single Wrapper for ALL popouts ───────────────────────────────
            // Positioned below the bar strip, centered on the hovered block.
            Wrapper {
                id: popouts
                barWidth: bar.width  // Pass the width to the wrapper

                // Clamp x so popup never goes off screen edges
                x: {
                    const ideal = currentCenter - implicitWidth / 2
                    const maxX  = bar.width - implicitWidth 
                    // SNAPPING LOGIC:
                    // If we are within 10px of the edge, snap perfectly to the edge
                    if (ideal <= 10) return 0;
                    if (ideal >= maxX - 10) return maxX;
                    
                    return ideal;
                }
                y: 35  // just below the bar strip with a small gap
                HoverHandler {
                    id: popoutHover
                    onHoveredChanged: {
                        if (hovered) {
                            closeDelay.stop()
                        } else {
                            closeDelay.start()
                        }
                    }
                }
            }

            // ── Mouse area over the bar strip only ───────────────────────────
            MouseArea {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 35
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                propagateComposedEvents: true

                onPositionChanged: event => checkPopout(event.x)

                onExited: {
                    // Small delay so mouse can travel into the popup without closing
                    closeDelay.start()
                }
            }

            // ── Delay before closing (lets mouse travel to popup) ────────────
            Timer {
                id: closeDelay
                interval: 100
                onTriggered: {
                    if (!popoutHover.hovered) {
                        popouts.hasCurrent = false
                    }
                }
            }

            // ── checkPopout: maps x position → block name + center ───────────
            function checkPopout(x: real): void {
                // Helper: is x within an item's horizontal bounds?
                function inBlock(item: Item): bool {
                    const left = item.mapToItem(allBlocks, 0, 0).x
                    return x >= left && x <= left + item.width
                }

                function centerOf(item: Item): real {
                    return item.mapToItem(allBlocks, 0, 0).x + item.width / 2
                }

                closeDelay.stop()

                if (inBlock(soundBlock)) {
                    popouts.currentName   = "sound"
                    popouts.currentCenter = centerOf(soundBlock)
                    popouts.hasCurrent    = true
                } else if (inBlock(musicBlock)) {
                    popouts.currentName   = "music"
                    popouts.currentCenter = centerOf(musicBlock)
                    popouts.hasCurrent    = true
                } else if (inBlock(btBlock)) {
                    popouts.currentName   = "bluetooth"
                    popouts.currentCenter = centerOf(btBlock)
                    popouts.hasCurrent    = true
                } else if (inBlock(networkBlock)) {
                    popouts.currentName   = "network"
                    popouts.currentCenter = centerOf(networkBlock)
                    popouts.hasCurrent    = true
                } else if (inBlock(batteryBlock)) {
                    popouts.currentName   = "battery"
                    popouts.currentCenter = centerOf(batteryBlock)
                    popouts.hasCurrent    = true
                } else if (inBlock(notificationBlock)) {
                    popouts.currentName   = "notification"
                    popouts.currentCenter = centerOf(notificationBlock)
                    popouts.hasCurrent    = true
                } else {
                    // Not over any popup block — start close delay
                    closeDelay.start()
                }
            }
        }
    }
}
