//@ pragma UseQApplication

import Quickshell
import "bar"
import QtQml

ShellRoot {
  Bar {}
   Connections {
        target: Quickshell

        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup()
            NotificationManager.send({
                icon:     "apps/scalable/quickshell.svg",
                title:    "Quickshell",
                message:  "Config reload",
                type:     "success",
                duration: 2000
            })
        }
    }
}
