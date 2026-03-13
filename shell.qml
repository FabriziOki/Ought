//@ pragma UseQApplication

import Quickshell
import "bar"
import QtQml

ShellRoot {
  Bar {}
   Connections {
        target: Quickshell

        function onReloadCompleted() {
            Quickshell.preventReloadPopup()
            NotificationManager.send({
                icon:     "󰄬",
                title:    "Shell reloaded",
                message:  "Config applied successfully",
                type:     "success",
                duration: 2500
            })
        }

        function onReloadFailed() {
            Quickshell.preventReloadPopup()
            NotificationManager.send({
                icon:     "󰅚",
                title:    "Reload failed",
                message:  "Check your config for errors",
                type:     "error",
                duration: 4000
            })
        }
    }
}

