import QtQuick

Canvas {
    id: wavyCircle
    
    // Default size, but you can override this wherever you use the component
    width: 100
    height: 100

    // --- CUSTOMIZATION PROPERTIES ---
    property color fillColor: "#fe8019" // A warm Gruvbox Orange 
    property int waves: 8               // How many bumps/valleys the circle has
    property real waveAmplitude: 6      // How dramatic/deep the waves are
    property real baseRadius: 35        // The core size of the circle before waves are added

    // --- NEW ROTATION PROPERTIES ---
    property bool isSpinning: false     // Turns the rotation on or off
    property int spinDuration: 2000     // Time in milliseconds for one full 360° spin (lower = faster)
    property bool spinClockwise: true   // Controls the direction of the spin
    // --- NEW BREATHING PROPERTIES ---
    property bool isBreathing: false    // Turns the morphing on/off
    property real minAmplitude: 2       // The lowest point of the wave
    property real maxAmplitude: 8       // The highest point of the wave
    property int breathDuration: 1500   // Milliseconds per pulse

    // The infinite breathing animation
    SequentialAnimation on waveAmplitude {
        loops: Animation.Infinite
        running: wavyCircle.isBreathing
        
        // Pause the animation at the current state if isBreathing becomes false
        paused: !wavyCircle.isBreathing

        NumberAnimation {
            to: wavyCircle.maxAmplitude
            duration: wavyCircle.breathDuration
            easing.type: Easing.InOutSine // InOutSine makes it feel incredibly natural
        }
        NumberAnimation {
            to: wavyCircle.minAmplitude
            duration: wavyCircle.breathDuration
            easing.type: Easing.InOutSine
        }
    }

    // Force the pivot point to be dead center
    transformOrigin: Item.Center

    // The infinite rotation animation
    RotationAnimation on rotation {
        loops: Animation.Infinite
        from: 0
        to: wavyCircle.spinClockwise ? 360 : -360 
        duration: wavyCircle.spinDuration
        
        running: true
        paused: !wavyCircle.isSpinning
    }
    // Force the canvas to redraw instantly if you animate or change these values
    onWavesChanged: requestPaint()
    onWaveAmplitudeChanged: requestPaint()
    onBaseRadiusChanged: requestPaint()
    onFillColorChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        var cx = width / 2;
        var cy = height / 2;

        ctx.reset();
        ctx.fillStyle = fillColor;
        ctx.beginPath();

        // We draw the circle by plotting 360 individual points (one for each degree).
        // Because the points are so close together, it creates a perfectly smooth curve.
        var steps = 360; 
        
        for (var i = 0; i <= steps; i++) {
            // Convert current step to radians
            var angle = (i * 2 * Math.PI) / steps;
            
            // THE MAGIC: The radius fluctuates based on a Sine wave!
            var currentRadius = baseRadius + (waveAmplitude * Math.sin(waves * angle));
            
            // Calculate the X and Y coordinates for this point
            var px = cx + currentRadius * Math.cos(angle);
            var py = cy + currentRadius * Math.sin(angle);

            if (i === 0) {
                ctx.moveTo(px, py); // Start drawing
            } else {
                ctx.lineTo(px, py); // Connect the dots
            }
        }

        ctx.closePath();
        ctx.fill();
    }
}
