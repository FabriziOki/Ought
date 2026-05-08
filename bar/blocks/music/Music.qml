pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import "../../components"

BarBlock {
    id: root
    visible: Pipewire.ready

    // ── Player state ──────────────────────────────────────────────────────────
    property PwNode sink: Pipewire.defaultAudioSink
    
    // 1. Grab the active player (exactly like you do in MusicContent.qml)
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

    // 2. Bind the status natively to the playback state
    property bool status: activePlayer?.playbackState === MprisPlaybackState.Playing
    
    // 3. Grab the player's name and force lowercase so your color checks still work
    property string currentPlayer: (activePlayer?.identity ?? "").toLowerCase()

    // ── Colors ────────────────────────────────────────────────────────────────
    property string colorZenOut:     "#a0af3a03"
    property string colorZenIn:      "#a0d79921"
    property string colorSpotifyOut: "#79740e"
    property string colorSpotifyIn:  "#98971a"
    property string colorIdle:       "#928374"
    property string colorIdleDim:    "#665c54"

    property string iconPath: "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/devices/symbolic/"

    // ── Block content ─────────────────────────────────────────────────────────
    content: Item {
        implicitWidth: 36
        implicitHeight: 36

        // WavyCircle {
        //     anchors.centerIn: parent
        //     width: 30; height: 30
        //     fillColor: {
        //         if (root.status && root.currentPlayer === "spotify")       return root.colorSpotifyOut
        //         if (root.status && root.currentPlayer.includes("zen")) return root.colorZenOut
        //         return root.colorIdleDim
        //     }
        //     Behavior on fillColor { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        //     waves: 9; waveAmplitude: 1; baseRadius: 15
        //     isSpinning: root.status; spinDuration: 10000
        //     opacity: {
        //         if(root.status)
        //             return 1  
        //         if(!root.status && Mpris.players.values.length)
        //             return 0.33
        //         if(!Mpris.players.values.length)
        //             return 0
        //     } 
        //     Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        //     isBreathing: root.status; minAmplitude: 0.75; maxAmplitude: 2; breathDuration: 1500
        // }

        // WavyCircle {
        //     anchors.centerIn: parent
        //     width: 30; height: 30
        //     fillColor: {
        //         if (root.status && root.currentPlayer === "spotify")       return root.colorSpotifyIn
        //         if (root.status && root.currentPlayer.includes("zen")) return root.colorZenIn
        //         return root.colorIdle
        //     }
        //     Behavior on fillColor { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        //     waves: 9; waveAmplitude: 1.5; baseRadius: 10
        //     isSpinning: root.status; spinDuration: 7500
        //     opacity: {
        //         if(root.status)
        //             return 1  
        //         if(!root.status && Mpris.players.values.length)
        //             return 0.33
        //         if(!Mpris.players.values.length)
        //             return 0
        //     } 
        //     Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        //     isBreathing: root.status; minAmplitude: 0.5; maxAmplitude: 3; breathDuration: 1500
        // }

        Image{
            anchors.centerIn: parent
            sourceSize: Qt.size(20, 20)
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: `file://${root.iconPath}media-cdrom-audio-symbolic.svg`
            opacity: {
                if(root.status || root.activePlayer)
                    return 1  
                if(!root.status)
                    return 0.33
            } 
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }

        // Text {
        //     anchors.centerIn: parent
        //     text: ""
        //     color: "#ebdbb2"
        //     font.pixelSize: {
        //         if(!root.activePlayer)
        //             return 18
        //         return 14
        //     }
        //     Behavior on font.pixelSize { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        //     font.family: "JetBrainsMono Nerd Font"
        //     opacity: {
        //         if(root.status || root.activePlayer)
        //             return 1  
        //         if(!root.status)
        //             return 0.33
        //     } 
        //     Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        // }
    }
}
