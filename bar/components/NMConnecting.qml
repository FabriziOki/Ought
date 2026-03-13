pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: nmConnecting
    implicitWidth: 24
    implicitHeight: 24

    // Updated properties to handle stages
    property int currentFrame: 0
    property int framesPerStage: 11
    property int stages: 3
    property int totalFrames: framesPerStage * stages
    
    property bool running: true
    property int frameInterval: 60 

    // 1. Outer repeater loops 3 times (for stage 01, 02, 03)
    Repeater {
        model: nmConnecting.stages
        
        // Intermediate Item to safely capture the stage index
        delegate: Item {
            id: stageItem
            anchors.fill: parent
            required property int index // Captures outer repeater's index (0, 1, 2)
            
            // Format stage string (01, 02, 03)
            property string stageStr: "0" + (index + 1)

            // 2. Inner repeater loops 11 times per stage
            Repeater {
                model: nmConnecting.framesPerStage
                
                delegate: Image {
                    required property int index // Captures inner repeater's index (0 to 10)
                    anchors.fill: parent
                                   
                    source: {
                        let frameNum = index + 1;
                        let padFrame = frameNum < 10 ? "0" : ""; 
                        
                        // Inject both the dynamic stage and the dynamic frame
                        return "/home/oki/.local/share/icons/Gruvbox-Plus-Dark/panel/24/nm-stage" + stageItem.stageStr + "-connecting" + padFrame + frameNum + ".svg";
                    }

                    sourceSize: Qt.size(nmConnecting.width, nmConnecting.height)
                    smooth: true
                    antialiasing: true
                    
                    // 3. Calculate absolute index to check visibility
                    // e.g., Stage 1, Frame 5 = (1 * 11) + 5 = absolute frame 16
                    visible: nmConnecting.currentFrame === (stageItem.index * nmConnecting.framesPerStage + index)
                }
            }
        }
    }

    // 4. Drive the animation loop across ALL 33 frames
    Timer {
        interval: nmConnecting.frameInterval
        running: nmConnecting.running
        repeat: true
        onTriggered: {
            // Modulo against totalFrames to loop seamlessly back to stage01
            nmConnecting.currentFrame = (nmConnecting.currentFrame + 1) % nmConnecting.totalFrames
        }
    }
}
