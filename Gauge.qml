import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    width: size
    height: size
    property real from: 0
    property real to: 100
    property real value: 0
    property string quantity: ""
    property string unit: ""
    property int size: 200
    property real arcBegin: -225
    property real arcEnd: -225
    property bool showBackground: true
    property bool showGlow: false
    property real lineWidth: 20
    property string colorCircle: "#00C0ff"
    property string colorBackground: "#000000"
    property bool displayInteger: true

    onValueChanged: {
        if (value > 0) {
            arcEnd = ((value - from) * 270 / Math.abs(to - from)) - 225;
        } else {
            arcEnd = -225;  // Ustawienie wskaźnika na start dla wartości <= 0
        }
        canvas.requestPaint()
    }
    Behavior on value {
        id: animationArcEnd
        enabled: true
        NumberAnimation {
            duration: 500
            easing.type: Easing.InOutCubic
        }
    }
    MouseArea {
        anchors.fill: parent
        onPressed: root.value=to;
        onReleased : root.value=from;
    }
    Canvas {
        id: canvas
        anchors.fill: root
        onPaint: {
            var ctx = getContext("2d")
            var x = width / 2
            var y = height / 2
            var start = Math.PI * (parent.arcBegin / 180)
            var end = Math.PI * (parent.arcEnd / 180)
            ctx.reset()
            ctx.beginPath();
            ctx.fillStyle = root.colorCircle
            ctx.textAlign="center";
            ctx.font = (root.size / 12)+"px Arial";
            ctx.textBaseline="middle";
            ctx.fillText(quantity, x, y - (root.size / 6));
            ctx.font = "bold "+(root.size / 5)+"px Arial";
            ctx.textBaseline="middle";
            ctx.fillText(root.displayInteger ? root.value.toFixed(0) : root.value.toFixed(2), x, y);
            ctx.font = (root.size / 12)+"px Arial";
            ctx.textBaseline="middle";
            ctx.fillText(unit, x, y + (root.size / 6));
            ctx.stroke()
            if (root.showBackground) {
                ctx.beginPath();
                ctx.arc(x, y, (width / 2) - (parent.lineWidth / 2) - 10, Math.PI * 0.75, Math.PI * 2.25, false)
                ctx.lineWidth = root.lineWidth
                ctx.strokeStyle = root.colorBackground
                ctx.stroke()
            }
            ctx.beginPath();
            ctx.arc(x, y, (width / 2) - (parent.lineWidth / 2) - 10, start, end, false)
            ctx.lineWidth = root.lineWidth
            ctx.strokeStyle = root.colorCircle
            ctx.stroke()
        }
    }
    Glow {
        id:glow
        visible: showGlow
        anchors.fill: root
        radius: 5
        spread: 0.0
        color: colorCircle
        source: canvas
    }
}
