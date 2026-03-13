pragma ComponentBehavior: Bound

import QtQuick
import "../blocks/music"          as Music
import "../blocks/network"        as Network
import "../blocks/bluetooth"      as Bluetooth
import "../blocks/sound"          as Sound
import "../blocks/battery"        as Battery
import "../blocks/notification"   as Notification

Item {
    id: root

    required property Item wrapper

    // Size wraps the active popout + padding
    readonly property Loader currentPopout: content.children
        .find(c => c instanceof Loader && c.name === root.wrapper.currentName) ?? null

    implicitWidth:  (currentPopout?.implicitWidth  ?? 0)
    implicitHeight: (currentPopout?.implicitHeight ?? 0)

    Item {
        id: content
        anchors.fill: parent

        // ── Register your popouts here ────────────────────────────────────────
        // Popout {
        //     name: "toast"
        //     sourceComponent: Notification.ToastContent {}
        // }

        Popout {
            name: "notification"
            sourceComponent: Notification.NotificationContent { wrapper: root.wrapper }
        }

        Popout {
            name: "music"
            sourceComponent: Component { Music.MusicContent { wrapper: root.wrapper } }
        }

        Popout {
            name: "network"
            sourceComponent: Component { Network.NetworkContent { wrapper: root.wrapper } }
        }

        Popout {
            name: "bluetooth"
            sourceComponent: Component { Bluetooth.BluetoothContent { wrapper: root.wrapper } }
        }

        Popout {
            name: "sound"
            sourceComponent: Component { Sound.SoundContent { wrapper: root.wrapper } }
        }

        Popout {
            name: "battery"
            sourceComponent: Component { Battery.BatteryContent { wrapper: root.wrapper } }
        }
    }

    // ── Reusable Popout component ─────────────────────────────────────────────
    component Popout: Loader {
        id: popout

        required property string name
        readonly property bool shouldBeActive: root.wrapper.currentName === name

        anchors.centerIn: parent
        opacity: 0
        scale: 0.9
        active: false

        states: State {
            name: "active"
            when: popout.shouldBeActive
            PropertyChanges { popout.active: true; popout.opacity: 1; popout.scale: 1 }
        }

        transitions: [
            Transition {
                from: ""; to: "active"
                SequentialAnimation {
                    PropertyAction  { target: popout; property: "active" }
                    NumberAnimation { properties: "opacity,scale"; duration: 150; easing.type: Easing.OutQuad }
                }
            },
            Transition {
                from: "active"; to: ""
                SequentialAnimation {
                    NumberAnimation { properties: "opacity,scale"; duration: 100; easing.type: Easing.OutQuad }
                    PropertyAction  { target: popout; property: "active" }
                }
            }
        ]
    }
}
