import QtQuick 6.0
import QtQuick.Layouts 6.0
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var levels: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    property bool enabled: true
    property bool paused: false

    implicitWidth: 92
    implicitHeight: 22

    Process {
        id: cavaProcess
        command: [Commands.cava, "-p", Commands.cavaConfig]
        running: root.enabled && !root.paused
        stdout: SplitParser {
            onRead: line => root.update(line)
        }
        onRunningChanged: {
            if (root.enabled && !root.paused && !running) {
                restartTimer.restart()
            }
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        repeat: false
        onTriggered: if (root.enabled && !cavaProcess.running) cavaProcess.running = true
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.rightMargin: 2
        spacing: 3

        Repeater {
            model: root.levels

            delegate: Rectangle {
                required property var modelData
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom
                implicitHeight: 4
                height: Math.max(3, parent.height * Number(modelData))
                radius: width / 2
                color: Theme.accentAlt
                opacity: 0.45 + Number(modelData) * 0.55
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        hoverEnabled: true
        onClicked: event => {
            if (event.button === Qt.RightButton) root.paused = !root.paused
        }
    }

    HoverTooltip {
        targetItem: root
        hovered: mouse.containsMouse
        text: root.paused ? "Audio visualizer paused" : "Audio visualizer"
        delay: 550
    }

    function update(line) {
        var values = String(line || "").trim().split(";")
        var next = []
        for (var i = 0; i < values.length; i++) {
            var value = Number(values[i])
            if (!isNaN(value)) {
                next.push(Math.max(0.08, Math.min(1, value / 8)))
            }
        }
        if (next.length > 0) {
            levels = next
        }
    }
}
