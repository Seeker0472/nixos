import QtQuick 6.0
import QtQuick.Layouts 6.0
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property int barCount: 12
    readonly property real minimumLevel: 0.08
    readonly property real inputMaximum: 8
    property var levels: [0.08, 0.08, 0.08, 0.08, 0.08, 0.08, 0.08, 0.08, 0.08, 0.08, 0.08, 0.08]
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
        spacing: 2

        Repeater {
            model: root.levels

            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignBottom
                Layout.minimumHeight: 3
                Layout.preferredHeight: Math.max(3, root.height * Number(modelData))
                implicitHeight: 3
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
        var text = String(line || "").trim()
        if (text.length === 0) return

        var values = text.split(";")
        var next = []
        for (var i = 0; i < values.length; i++) {
            var token = values[i].trim()
            if (token.length === 0) continue

            var value = Number(token)
            if (!isNaN(value) && isFinite(value)) {
                next.push(Math.max(root.minimumLevel, Math.min(1, value / root.inputMaximum)))
            }
        }
        if (next.length === root.barCount) {
            levels = next
        }
    }
}
