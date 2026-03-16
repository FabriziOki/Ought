pragma ComponentBehavior: Bound

import QtQuick
import "../components"

Item {
    id: root

    // ── Public API (set by Bar.qml) ───────────────────────────────────────────
    property string currentName: ""
    property real currentCenter: 0   // X center of the hovered block in bar coords
    property bool hasCurrent: false

    // ── Derived ───────────────────────────────────────────────────────────────
    // Add this property
    property real _lastWidth: 0
    
    // Replace nonAnimWidth
    readonly property real nonAnimWidth: {
        if (hasCurrent) {
            const w = content.item?.implicitWidth ?? 0
            if (w > 0) _lastWidth = w
            return w
        }
        return _lastWidth  // hold last width while height closes
    }

    readonly property real nonAnimHeight: hasCurrent ? (content.item?.implicitHeight ?? 0) : 0

    property real barWidth: 0
    readonly property bool isAtLeftEdge: x === 0
    readonly property bool isAtRightEdge: barWidth > 0 && x >= (barWidth - implicitWidth - 1)

    // ── Animation Variables ────────────────────────────────────────────────
    readonly property var easingType: Easing.OutExpo
    readonly property int animationDuration: 500

    // ── Size morphs to content ────────────────────────────────────────────────
    implicitWidth:  nonAnimWidth
    implicitHeight: nonAnimHeight

    visible: implicitHeight > 0
    // clip: true

    Behavior on implicitWidth {
        enabled: false
        NumberAnimation { duration: root.animationDuration ; easing.type: root.easingType }
    }

    Behavior on implicitHeight {
        enabled: root.implicitWidth > 0
        NumberAnimation { duration: root.animationDuration ; easing.type: root.easingType }
    }

    Background {
        isAtLeftEdge: root.isAtLeftEdge
        isAtRightEdge: root.isAtRightEdge
        opacity: root.hasCurrent ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: root.animationDuration ; easing.type: root.easingType } }
    }
    // ── Item for Clipping Content ────────────────────────────────────────────────────────
    Item {
        id: clipBox
        anchors.fill: parent
        clip: true
    
        // ── Content loader ────────────────────────────────────────────────────────
        Loader {
            id: content

            anchors.centerIn: parent
            opacity: 1
            scale: 1
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
                        NumberAnimation { properties: "opacity,scale"; duration: root.animationDuration ; easing.type: root.easingType }
                    }
                },
                Transition {
                    from: "active"; to: ""
                    SequentialAnimation {
                        NumberAnimation { properties: "opacity,scale"; duration: root.animationDuration ; easing.type: root.easingType }
                        PropertyAction  { property: "active" }
                    }
                }
            ]
        }
    }
}
