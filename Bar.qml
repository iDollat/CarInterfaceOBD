import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    width: size
    height: size / 4 // Adjust the height for a horizontal bar
    property real from: 0
    property real to: 100
    property real value: 0
    property string quantity: ""
    property string unit: ""
    property int size: 200
    property bool showBackground: true
    property bool showGlow: false
    property real lineWidth: 20
    property string colorBar: "#00C0ff"
    property string colorBackground: "#000000"

    onValueChanged: {
        canvas.requestPaint()
    }

    Behavior on value {
        id: animationBarFill
        enabled: true
        NumberAnimation {
            duration: 500
            easing.type: Easing.InOutCubic
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: root.value = to
        onReleased: root.value = from
    }

    Canvas {
        id: canvas
        anchors.fill: root

        onPaint: {
            var ctx = getContext("2d")
            var x = 0
            var y = height / 2 // Adjusted position for the bar
            var fillWidth = ((value - from) / (to - from)) * width

            ctx.reset()

            // Draw quantity text above the bar
            ctx.fillStyle = root.colorBar
            ctx.textAlign = "center"
            ctx.font = (root.size / 24) + "px Arial" // Reduced font size
            ctx.textBaseline = "middle"
            ctx.fillText(quantity, width - width / 4,  y - root.size / 12) // Positioned above the bar

            // Draw unit and value texts above the bar
            ctx.font = "bold " + (root.size / 12) + "px Arial" // Reduced font size
            ctx.fillText(root.value.toFixed(1), width / 2, y - root.size / 12) // Positioned above the bar
            ctx.font = (root.size / 22) + "px Arial" // Reduced font size
            ctx.fillText(unit, width / 2, y) // Positioned above the bar

            // Draw background bar
            if (root.showBackground) {
                ctx.beginPath()
                ctx.rect(x, y - root.lineWidth / 2, width, root.lineWidth)
                ctx.fillStyle = root.colorBackground
                ctx.fill()
            }

            // Draw filled bar
            ctx.beginPath()
            ctx.rect(x, y - root.lineWidth / 2, fillWidth, root.lineWidth)
            ctx.fillStyle = root.colorBar
            ctx.fill()
        }
    }

    Glow {
        id: glow
        visible: showGlow
        anchors.fill: root
        radius: 5
        spread: 0.0
        color: colorBar
        source: canvas
    }
}
