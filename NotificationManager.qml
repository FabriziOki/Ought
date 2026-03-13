pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property var current: null   // { icon, title, message, type, duration }
    property bool active: false

    // Private queue — plain JS array
    property var _queue: []

    function send(notif): void {
        if (!active) {
            _show(notif)
        } else {
            _queue.push(notif)
        }
    }

    function _show(notif): void {
        current = notif
        active = true
        dismissTimer.interval = notif.duration ?? 2500
        dismissTimer.restart()
    }

    function _next(): void {
        if (_queue.length > 0) {
            _show(_queue.shift())
        } else {
            active = false
            current = null
        }
    }

    Timer {
        id: dismissTimer
        onTriggered: root._next()
    }
}
