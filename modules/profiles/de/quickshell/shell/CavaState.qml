pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int barCount: 12
    readonly property real minimumLevel: 0.08
    readonly property real inputMaximum: 8
    readonly property bool active: ShellState.audioReady && !ShellState.onBattery
    property var levels: defaultLevels()
    property bool paused: false
    property int restartDelay: 1000

    Process {
        id: cavaProcess
        command: [Commands.cava, "-p", Commands.cavaConfig]
        running: false
        stdout: SplitParser {
            onRead: line => root.update(line)
        }
        onRunningChanged: {
            if (!running) {
                stableTimer.stop()
                if (root.active && !root.paused) restartTimer.restart()
            } else {
                stableTimer.restart()
            }
        }
    }

    Timer {
        id: restartTimer
        interval: root.restartDelay
        repeat: false
        onTriggered: {
            if (root.active && !root.paused && !cavaProcess.running) {
                root.restartDelay = Math.min(root.restartDelay * 2, 30000)
                cavaProcess.running = true
            }
        }
    }

    Timer {
        id: stableTimer
        interval: 5000
        repeat: false
        onTriggered: root.restartDelay = 1000
    }

    onActiveChanged: {
        syncProcess()
    }

    onPausedChanged: {
        syncProcess()
    }

    Component.onCompleted: syncProcess()

    function syncProcess() {
        restartTimer.stop()
        stableTimer.stop()
        if (!root.active || root.paused) {
            cavaProcess.running = false
            levels = defaultLevels()
        } else if (root.active && !cavaProcess.running) {
            root.restartDelay = 1000
            restartTimer.restart()
        }
    }

    function defaultLevels() {
        var values = []
        for (var i = 0; i < root.barCount; i++) values.push(root.minimumLevel)
        return values
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
        if (next.length === root.barCount) levels = next
    }
}
