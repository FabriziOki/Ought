pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import "../components"
import "../../"

// One Wrapper instance lives in the bar window, below the bar strip.
// Bar.qml calls checkPopout(x) on mouse move to set currentName + currentCenter.
// The Wrapper morphs its implicitWidth/Height to the active content's size,
// and is positioned by Bar.qml to center on currentCenter.
Item {
    id: root

    // ── Public API (set by Bar.qml) ───────────────────────────────────────────
    property string currentName: ""
    property real currentCenter: 0   // X center of the hovered block in bar coords
    property bool hasCurrent: false

    // ── Derived ───────────────────────────────────────────────────────────────
    readonly property real nonAnimWidth:  hasCurrent ? (content.item?.implicitWidth  ?? 0) : 0
    readonly property real nonAnimHeight: hasCurrent ? (content.item?.implicitHeight ?? 0) : 0

    property real barWidth: 0
    readonly property bool isAtLeftEdge: x === 0
    readonly property bool isAtRightEdge: barWidth > 0 && x >= (barWidth - implicitWidth - 1)

    // ── Size morphs to content ────────────────────────────────────────────────
    implicitWidth:  nonAnimWidth
    implicitHeight: nonAnimHeight

    visible: implicitWidth > 0 && implicitHeight > 0
    // clip: true

    Behavior on implicitWidth {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Behavior on implicitHeight {
        enabled: root.implicitWidth > 0
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Background {
        isAtLeftEdge: root.isAtLeftEdge
        isAtRightEdge: root.isAtRightEdge
        opacity: root.hasCurrent ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    }
    // ── Content loader ────────────────────────────────────────────────────────
    Loader {
        id: content

        anchors.centerIn: parent
        opacity: 0
        scale: 0.9
        active: root.hasCurrent

        sourceComponent: Content { wrapper: root }

        states: State {
            name: "active"
            when: root.hasCurrent
            PropertyChanges { content.opacity: 1; content.scale: 1 }
        }

        transitions: [
            Transition {
                from: ""; to: "active"
                SequentialAnimation {
                    PropertyAction  { property: "active" }
                    NumberAnimation { properties: "opacity,scale"; duration: 150; easing.type: Easing.OutQuad }
                }
            },
            Transition {
                from: "active"; to: ""
                SequentialAnimation {
                    NumberAnimation { properties: "opacity,scale"; duration: 100; easing.type: Easing.OutQuad }
                    PropertyAction  { property: "active" }
                }
            }
        ]
    }
}
