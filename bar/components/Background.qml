import QtQuick
import QtQuick.Shapes
import "../../"

Shape {
    id: root
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    // The radius for both the concave scoops and convex corners
    property real r: 12
    
    // To make the most of this effect with your warm system theme, 
    // ensure this flat color matches the top bar perfectly.
    property color popupColor: Theme.get.popupBgColor
    // Edge detection flags
    property bool isAtLeftEdge: false
    property bool isAtRightEdge: false
    // Shrink radius to near-zero to "disable" the scoop without breaking the path
    readonly property real lR: isAtLeftEdge ? 0.001 : r
    readonly property real rR: isAtRightEdge ? 0.001 : r

    ShapePath {
        strokeWidth: -1   // Essential for the seamless liquid blend
        fillColor: root.popupColor

        // Start at the far-left tip of the left scoop
        startX: -root.r
        startY: 0

        // 1. Left scoop (flares outward to meet the bar)
        PathArc {
            x: 0; y: root.r
            radiusX: root.r; radiusY: root.r
            direction: PathArc.Clockwise
        }

        // 2. Left straight edge
        PathLine { x: 0; y: root.height - root.r }

        // 3. Bottom-left corner (standard convex rounding)
        PathArc {
            x: root.r; y: root.height
            radiusX: root.r; radiusY: root.r
            direction: PathArc.Counterclockwise
        }

        // 4. Bottom straight edge
        PathLine { x: root.width - root.r; y: root.height }

        // 5. Bottom-right corner (standard convex rounding)
        PathArc {
            x: root.width; y: root.height - root.r
            radiusX: root.r; radiusY: root.r
            direction: PathArc.Counterclockwise
        }

        // 6. Right straight edge (go all the way to 0 if at edge)
        PathLine { x: root.width; y: root.isAtRightEdge ? 0 : root.r }

        // 7. Right scoop
        PathArc {
            x: root.isAtRightEdge ? root.width : root.width + root.r
            y: 0
            radiusX: root.rR; radiusY: root.rR
            direction: PathArc.Clockwise
        }        
        // Qt auto-closes the path with a straight line across the top,
        // which sits perfectly flush against your top bar!
    }
}
