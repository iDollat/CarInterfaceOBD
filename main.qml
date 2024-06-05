import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

ApplicationWindow {
    id: applicationWindow
    Material.theme: Material.Dark
    Material.accent: Material.Blue
    Material.primary: Material.Blue
    width: 800
    height: 600
    visible: true
    title: qsTr("Car Info")
    property bool disconnect: true


    Timer {
        id: delayTimer
        interval: 1000
        repeat: false
        running: false
        onTriggered: {
            //console.log("Delay simer start")
            obdTimer.start();}
    }

    Timer {
        id: obdTimer
        interval: 50  // Co 50 ms
        running: false
        repeat: true
        onTriggered: {
            //console.log("Wysyłanie komend OBD-II");
            bledevice.writeData("01 0D");  // Speed
            bledevice.writeData("01 0C");  // RPM
            bledevice.writeData("01 05");  // Coolant Temperature
            bledevice.writeData("01 0B");  // Boost
            bledevice.writeData("01 2F");  // Fuel Level
            bledevice.writeData("01 0F");  // Intake Air Temperature
            bledevice.writeData("01 04");  // Engine Load
        }
    }

    header: ToolBar {
        contentHeight: toolButtonScan.implicitHeight
        background: Rectangle {
            color: "#1C1B1F"
        }

        Row {
            ToolButton {
                id: toolButtonScan
                text: "\u2630"
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                onClicked: {
                    scanButton.enabled = true;
                    scanButton.text = disconnect ? "Scan" : "Disconnect"
                    drawer.open()
                }
            }
        }
    }

    Drawer {
        id: drawer
        width: 250
        height: applicationWindow.height
        Button {
            id: scanButton
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 20
            text: "Scan"
            onClicked: {
                listView.enabled = false
                if (disconnect) {
                    text = "Scanning..."
                    enabled = false
                    busyIndicator.running = true
                    bledevice.startScan()
                } else {
                    bledevice.disconnectFromDevice()
                }
            }
        }
        ListView {
            id: listView
            anchors.fill: parent
            anchors.topMargin: 50
            anchors.bottomMargin: 50
            width: parent.width
            clip: true
            model: bledevice.deviceListModel
            delegate: RadioDelegate {
                id: radioDelegate
                text: (index + 1) + ". " + modelData
                width: listView.width
                onCheckedChanged: {
                    console.log("checked", modelData, index)
                    scanButton.enabled = false;
                    scanButton.text = "Connecting to " + modelData
                    listView.enabled = false;
                    bledevice.startConnect(index)
                }
            }
        }
        BusyIndicator {
            id: busyIndicator
            Material.accent: "Blue"
            anchors.centerIn: parent
            running: false
        }
    }

    Bar {
        id: barRpm
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -0.25 * parent.height
        size: applicationWindow.width * 0.4375
        colorBar: "#00C0ff"
        colorBackground: "#202020"
        lineWidth: 0.1 * width
        showGlow: true
        quantity: "RPM x 1000"
        from: 0
        to: 8
        value: from
    }

    Row {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -0.2 * parent.width
        Column {
            spacing: applicationWindow.height * 0.01
            Text {
                id: dateText
                text: Qt.formatDate(new Date(), "yyyy-MM-dd")
                color: "#00C0ff"
                font.pixelSize: applicationWindow.width * 0.02
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: timeText
                text: Qt.formatTime(new Date(), "HH:mm:ss")
                color: "#00C0ff"
                font.pixelSize: applicationWindow.width * 0.02
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Timer {
                interval: 1000
                repeat: true
                running: true
                onTriggered: {
                    dateText.text = Qt.formatDate(new Date(), "yyyy-MM-dd")
                    timeText.text = Qt.formatTime(new Date(), "HH:mm:ss")
                }
            }
        }
    }

    Gauge {
        id: gaugeSpeed
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        size: applicationWindow.width * 0.25
        colorCircle: "#00C0ff"
        colorBackground: "#202020"
        lineWidth: 0.1 * width
        showGlow: true
        unit: "km/h"
        from: 0
        to: 240
        value: from
    }

    Column {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 0.2 * parent.width

        Text {
            id: timerLabel
            color: "#00C0ff"
            font.pixelSize: applicationWindow.width * 0.03
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: timerResult
            color: "#00C0ff"
            font.pixelSize: applicationWindow.width * 0.03
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Gauge {
        id: gaugeCoolant
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -0.35 * parent.width
        anchors.verticalCenterOffset: 0.1 * parent.height
        size: applicationWindow.width * 0.125
        colorCircle: "#00C0ff"
        colorBackground: "#202020"
        lineWidth: 0.1 * width
        showGlow: true
        quantity: "Coolant"
        unit: "°C"
        from: 50
        to: 130
        value: from
    }

    Gauge {
        id: gaugeFuel
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 0.35 * parent.width
        anchors.verticalCenterOffset: 0.1 * parent.height
        size: applicationWindow.width * 0.125
        colorCircle: "#00C0ff"
        colorBackground: "#202020"
        lineWidth: 0.1 * width
        showGlow: true
        quantity: "Fuel"
        unit: "E / F"
        from: 0
        to: 100
        value: from
    }

    Gauge {
        id: gaugeIntake
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -0.15 * parent.width
        anchors.verticalCenterOffset: 0.23 * parent.height
        size: applicationWindow.width * 0.125
        colorCircle: "#00C0ff"
        colorBackground: "#202020"
        lineWidth: 0.1 * width
        showGlow: true
        quantity: "Intake"
        unit: "°C"
        from: 0
        to: 40
        value: from
    }

    Gauge {
        id: gaugeBoost
        anchors.centerIn: parent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenterOffset: 0.23 * parent.height
        size: applicationWindow.width * 0.125
        colorCircle: "#00C0ff"
        colorBackground: "#202020"
        lineWidth: 0.1 * width
        showGlow: true
        displayInteger: false
        quantity: "Boost"
        unit: "bar"
        from: 0
        to: 1.6
        value: from
    }

    Gauge {
        id: gaugeLoad
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 0.15 * parent.width
        anchors.verticalCenterOffset: 0.23 * parent.height
        size: applicationWindow.width * 0.125
        colorCircle: "#00C0ff"
        colorBackground: "#202020"
        lineWidth: 0.1 * width
        showGlow: true
        quantity: "Load"
        unit: "%"
        from: 0
        to: 100
        value: from
    }

    Connections {
        target: bledevice
        function onNewData(data) {

            //console.log("Data:", data);
            var dataString = data.toString();
            //console.log("Converted data:", dataString);

            processData(dataString);
        }
        function onScanningFinished() {
            listView.enabled = true
            scanButton.enabled = true
            scanButton.text = "Scan"
            listView.enabled = true
            busyIndicator.running = false
            scanButton.enabled = true
            console.log("ScanningFinished")
        }
        function onConnectionStart() {
            disconnect = false
            busyIndicator.running = false
            drawer.close()
            console.log("ConnectionStart")
            delayTimer.start();  // Rozpoczęcie cyklicznego pobierania danych po 200 ms delay
        }
        function processData(data) {

            data = data.replace(/\s+/g, '');
            var parts = data.slice(2).match(/.{1,2}/g);
            var pid = parts[0];  // PID
            var a = parseInt(parts[1], 16);

            switch(pid) {
            case "0D":  // Speed
                var speed = a;
                gaugeSpeed.value = speed;

                if (speed >= 20) // 100 -> 20
                    gaugeSpeed.colorBar = "orange"
                else if (speed >= 50) // 160 -> 50
                    gaugeSpeed.colorBar = "red"
                else
                    gaugeSpeed.colorBar = "#00C0ff"

                break;
            case "0C":  // RPM
                if (parts.length >= 3) {
                    var b = parseInt(parts[2], 16);
                    var rpm = (256 * a + b) / 4;

                    //console.log("parts[2]", parts[2]);

                    if (rpm >= 2000) // 3000 -> 2000
                        barRpm.colorBar = "orange"
                    else if (rpm >= 2500) // 4500 -> 2500
                        barRpm.colorBar = "red"
                    else
                        barRpm.colorBar = "#00C0ff"

                    barRpm.value = rpm / 1000;
                }
                break;
            case "05":  // Coolant Temperature
                var temp = a - 40;

                if (temp >= 89)
                    gaugeCoolant.colorCircle = "green"
                else if (temp >= 112)
                    gaugeCoolant.colorCircle = "red"
                else
                    gaugeCoolant.colorCircle = "#00C0ff"

                gaugeCoolant.value = temp;
                break;
            case "0B":  // Boost
                var boost = (a / 100) - 1;

                if (boost >= 1)
                    gaugeBoost.colorCircle = "orange"
                else if (boost >= 1.4)
                    gaugeBoost.colorCircle = "red"
                else
                    gaugeBoost.colorCircle = "#00C0ff"

                gaugeBoost.value = boost;
                break;
            case "2F":  // Fuel Level
                var fuel = (100 / 255) * a;

                if (fuel < 10)
                    gaugeFuel.colorCircle = "red"
                else
                    gaugeFuel.colorCircle = "#00C0ff"

                gaugeFuel.value = fuel;
                break;
            case "0F":  // Intake Air Temperature
                var intakeTemp = a - 40

                gaugeIntake.value = intakeTemp
                break;
            case "04":  // Engine Load
                var load = (100 / 255) * a;

                if (load >= 30)
                    gaugeLoad.colorCircle = "green"
                else if (load >= 60)
                    gaugeLoad.colorCircle = "orange"
                else if (load >= 90)
                    gaugeLoad.colorCircle = "red"
                else
                    gaugeLoad.colorCircle = "#00C0ff"

                gaugeLoad.value = load;
                break;
            default:
                console.log("Nieznany PID:", pid);
                break;
            }
        }

        function onConnectionEnd() {
            disconnect = true
            scanButton.text = "Connection End - Scan again"
            scanButton.enabled = true
            bledevice.resetDeviceListModel()
            obdTimer.stop();
            console.log("ConnectionEnd")
        }
    }
}
