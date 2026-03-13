import QtQuick
import Quickshell

Item {
    id: loadingSpinner
    // Scale it down to fit within your BarBlock's 30px height limit
    width: 24
    height: 24
    
    // Explicitly define implicit sizes so BarBlock can read them
    implicitWidth: 24
    implicitHeight: 24

    // Expose properties for easy customization
    property int currentFrame: 1
    property int frameCount: 11
    property bool running: true
    
    // 50ms per frame = 600ms per full rotation (adjust for speed)
    property int frameInterval: 60 

    // 1. Preload all 12 frames to prevent flickering
    Repeater {
        model: loadingSpinner.frameCount
        
        Image {
            anchors.fill: parent
                                    
            source: {
                // Add 1 so the index counts from 1 to 12 instead of 0 to 11
                let frameNum = index + 1; 
                
                // Add the leading zero if the number is single-digit
                let pad = frameNum < 10 ? "0" : ""; 
                
                return "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/animations/24/nm-stage01-connecting" + pad + frameNum + ".svg";
            }

            // Render at the exact size needed to keep it crisp
            sourceSize: Qt.size(loadingSpinner.width, loadingSpinner.height)
            
            smooth: true
            antialiasing: true
            
            // 2. Only show the image if its index matches the current frame
            visible: loadingSpinner.currentFrame === index
        }
    }

    // 3. Drive the animation loop
    Timer {
        interval: loadingSpinner.frameInterval
        running: loadingSpinner.running
        repeat: true
        onTriggered: {
            loadingSpinner.currentFrame = (loadingSpinner.currentFrame + 1) % loadingSpinner.frameCount
        }
    }
}
