pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import "../../../"

Item {
    id: root

    // ── Required by Content.qml ───────────────────────────────────────────────
    required property Item wrapper

    // ── Local state ───────────────────────────────────────────────────────────
    property string iconPath:  "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/panel/24/"
    property string iconPath2: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/actions/24/"
    property PwNode sink: Pipewire.defaultAudioSink
    property var activePlayer: {
        const players = Mpris.players.values;
        if (players.length === 0) return null;

        // Helper to check names
        const isSpotify = (p) => p.identity.toLowerCase().includes("spotify");
        const isZen = (p) => p.identity.toLowerCase().includes("zen") || p.identity.toLowerCase().includes("firefox");

        // 1. Is Spotify currently PLAYING? (Top Priority)
        let player = players.find(p => p.playbackState === MprisPlaybackState.Playing && isSpotify(p));
        if (player) return player;

        // 2. Is Zen currently PLAYING?
        player = players.find(p => p.playbackState === MprisPlaybackState.Playing && isZen(p));
        if (player) return player;

        // 3. Is literally ANYTHING else playing? (Don't show a paused Spotify if a video is playing)
        player = players.find(p => p.playbackState === MprisPlaybackState.Playing);
        if (player) return player;

        // 4. Nothing is playing. Fallback to paused players, preferring Spotify, then Zen.
        player = players.find(p => isSpotify(p));
        if (player) return player;
        
        player = players.find(p => isZen(p));
        if (player) return player;

        // 5. Absolute fallback (e.g., VLC is open and paused)
        return players[0];
    }    

    // ── Size — Wrapper reads these to morph its own size ──────────────────────
    implicitWidth:  400
    implicitHeight: activePlayer ? 180 : 150

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.activePlayer?.playbackState === MprisPlaybackState.Playing
        onTriggered: root.activePlayer?.positionChanged()
    }

    FrameAnimation {
        running: root.activePlayer?.playbackState === MprisPlaybackState.Playing
        onTriggered: root.activePlayer?.positionChanged()
    }
    function formatTime(s: real): string {
        const m = Math.floor(s / 60)
        return `${m}:${String(Math.floor(s % 60)).padStart(2, "0")}`
    }
    // ── Content ───────────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // ── Album art + track info ────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            Image {
                id: albumArt
                Layout.preferredWidth: 120
                Layout.preferredHeight: 120
                source: root.activePlayer.trackArtUrl 
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
                cache: true
                asynchronous: true
                sourceSize: Qt.size(480, 480)
                opacity: status === Image.Ready ? 1.0 : 0.0
                Behavior on opacity { 
                    NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } 
                }

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: albumArt.width
                        height: albumArt.height
                        radius: 10
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: Theme.get.popupItemBgOnColor
                    radius: 10
                    z: -1
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MarqueeText {
                    text: root.activePlayer?.trackTitle ?? "No Music Playing"
                    color: "#ebdbb2"
                    font.pixelSize: 20
                    font.family: "JetBrainsMono Nerd Font"
                    Layout.fillWidth: true
                    font.weight: 600
                }


                MarqueeText {
                    text: root.activePlayer?.trackArtists  ?? ""
                    color: "#d5c4a1"
                    font.pixelSize: 18
                    font.family: "JetBrainsMono Nerd Font"
                    Layout.fillWidth: true
                    font.weight: 200
                }

                Item {
                    Layout.topMargin: 25
                }

                // Player identity row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Image {
                        source: {
                            if (!root.activePlayer) return `file://${root.iconPath2}question.svg`
                            if (root.activePlayer.identity === "Spotify")           return `file://${root.iconPath}spotify-indicator.svg`
                            if (root.activePlayer.identity.includes("zen"))         return `file://${root.iconPath2}web-browser.svg`
                            return `file://${root.iconPath2}question.svg`
                        }
                        sourceSize: Qt.size(20, 20)
                    }

                    Text {
                        text: root.activePlayer?.identity ?? "Unknown Player"
                        color: "#ebdbb2"
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                        font.weight: 200
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // Playback controls
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 5
                    spacing: 15

                    MouseArea {
                        Layout.preferredWidth: 28; Layout.preferredHeight: 28
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activePlayer?.previous()
                        
                        HoverHandler { id: prevHover }
                        
                        Image { 
                            anchors.fill: parent
                            source: `file://${root.iconPath2}go-previous.svg`
                            opacity: prevHover.hovered ? 1.0 : 0.5
                            scale: prevHover.hovered ? 1.2 : 1.0
                            
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                            Behavior on scale   { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        }
                    }

                    MouseArea {
                        Layout.preferredWidth: 28; Layout.preferredHeight: 28
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activePlayer?.seek(-5)
                        
                        HoverHandler { id: seekBackHover }
                        
                        Image { 
                            anchors.fill: parent
                            source: `file://${root.iconPath2}media-seek-backward.svg`
                            opacity: seekBackHover.hovered ? 1.0 : 0.5
                            scale: seekBackHover.hovered ? 1.2 : 1.0
                            
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                            Behavior on scale   { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        }
                    }

                    MouseArea {
                        Layout.preferredWidth: 28; Layout.preferredHeight: 28
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activePlayer?.togglePlaying()
                        
                        HoverHandler { id: playHover }
                        
                        Image {
                            anchors.fill: parent
                            source: (root.activePlayer?.isPlaying ?? false)
                                ? `file://${root.iconPath2}media-playback-pause.svg`
                                : `file://${root.iconPath2}media-play.svg`
                            opacity: playHover.hovered ? 1.0 : 0.5
                            scale: playHover.hovered ? 1.2 : 1.0
                            
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                            Behavior on scale   { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        }
                    }

                    MouseArea {
                        Layout.preferredWidth: 28; Layout.preferredHeight: 28
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activePlayer?.seek(5)
                        
                        HoverHandler { id: seekFwdHover }
                        
                        Image { 
                            anchors.fill: parent
                            source: `file://${root.iconPath2}media-seek-forward.svg`
                            opacity: seekFwdHover.hovered ? 1.0 : 0.5
                            scale: seekFwdHover.hovered ? 1.2 : 1.0
                            
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                            Behavior on scale   { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        }
                    }

                    MouseArea {
                        Layout.preferredWidth: 28; Layout.preferredHeight: 28
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activePlayer?.next()
                        
                        HoverHandler { id: nextHover }
                        
                        Image {
                            anchors.fill: parent
                            source: `file://${root.iconPath2}go-next.svg`
                            opacity: nextHover.hovered ? 1.0 : 0.5
                            scale: nextHover.hovered ? 1.2 : 1.0
                            
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                            Behavior on scale   { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
        
            Text {
                text: root.formatTime(root.activePlayer.position) || "0:00" 
                color: "#a89984"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
            }
        
            Slider {
                Layout.fillWidth: true
                from:  0
                to:    root.activePlayer?.length ?? 1
                value: root.activePlayer?.position ?? 0
                
                onMoved: {
                    if (root.activePlayer?.canSeek)
                        root.activePlayer.position = value
                }        

                background: Rectangle {
                    x: parent.leftPadding
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    width: parent.availableWidth
                    implicitWidth: 200; implicitHeight: 4
                    height: parent.hovered ? 6 : 4
                    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    radius: height / 2
                    color: Theme.get.progressBarBg
                    opacity: (root.activePlayer) ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        
                    Rectangle {
                        width: parent.parent.visualPosition * parent.width
                        height: parent.height
                        radius: parent.radius
                        color: "#928374"
                    }
                }
        
                handle: Rectangle {
                    x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    implicitWidth:  parent.hovered ? 14 : 0
                    implicitHeight: parent.hovered ? 14 : 0
                    radius: 7
                    color: "#ebdbb2"
                    opacity: (root.activePlayer) ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on implicitWidth  { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on implicitHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
            }
        
            Text {
                text: root.formatTime(root.activePlayer.length - root.activePlayer.position) || "0:00"
                color: "#a89984"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
            }
        }
    }

    // ── Reusable Marquee Component ────────────────────────────────────────────
    component MarqueeText: Item {
        id: container
        
        // Expose properties so we can style it just like a normal Text item
        property alias text: mainText.text
        property alias color: mainText.color
        property alias font: mainText.font
        
        // Give the container the same height as the text so Layouts work properly
        implicitHeight: mainText.implicitHeight
        
        // Crucial: hide any text that spills outside the boundaries!
        clip: true 

        Text {
            id: mainText
            // Do NOT use elide here! We want the text to fully render its true width.
            
            SequentialAnimation on x {
                loops: Animation.Infinite
                // Only run the animation if the text is physically wider than the container
                running: mainText.implicitWidth > container.width && container.width > 0

                // 1. Wait for 2 seconds before moving
                PauseAnimation { duration: 2000 }
                
                // 2. Smoothly slide to the left
                NumberAnimation {
                    to: container.width - mainText.implicitWidth
                    // Calculate duration dynamically: longer text takes longer to scroll
                    duration: (mainText.implicitWidth - container.width) * 30 
                    easing.type: Easing.InOutQuad
                }
                
                // 3. Wait for 2 seconds at the end of the text
                PauseAnimation { duration: 2000 }
                
                // 4. Smoothly slide back to the start
                NumberAnimation {
                    to: 0
                    duration: (mainText.implicitWidth - container.width) * 30
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    PwObjectTracker { objects: [root.sink] }
}
