pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string confirmationAction: ""
    property string confirmationLabel: ""
    property bool running: false
    property string errorMessage: ""

    readonly property bool confirmationPending: root.confirmationAction.length > 0

    Process {
        id: powerProcess
        stdout: StdioCollector { id: powerOutput }
        stderr: StdioCollector { id: powerError }
        onExited: exitCode => {
            root.running = false
            if (exitCode !== 0) {
                root.errorMessage = root.cleanError(powerError.text || powerOutput.text, "Power action failed")
                errorTimer.restart()
            } else {
                root.errorMessage = ""
                UiState.closePopup()
            }
        }
    }

    Timer {
        id: confirmationTimer
        interval: 5000
        repeat: false
        onTriggered: root.cancelConfirmation()
    }

    Timer {
        id: errorTimer
        interval: 5000
        repeat: false
        onTriggered: root.errorMessage = ""
    }

    Connections {
        target: UiState
        function onPopupOpenChanged() {
            if (!UiState.popupOpen) root.cancelConfirmation()
        }
        function onPopupPageChanged() {
            if (UiState.popupPage !== "power") root.cancelConfirmation()
        }
    }

    function request(action, label) {
        if (root.running) return
        root.confirmationAction = String(action || "")
        root.confirmationLabel = String(label || action || "power action")
        root.errorMessage = ""
        confirmationTimer.restart()
    }

    function cancelConfirmation() {
        confirmationTimer.stop()
        root.confirmationAction = ""
        root.confirmationLabel = ""
    }

    function confirm() {
        if (!root.confirmationPending || root.running) return
        var action = root.confirmationAction
        root.cancelConfirmation()
        root.running = true
        powerProcess.command = [Commands.systemctl, action]
        powerProcess.running = true
    }

    function runImmediate(command) {
        if (root.running) return
        root.cancelConfirmation()
        root.errorMessage = ""
        root.running = true
        powerProcess.command = command
        powerProcess.running = true
    }

    function cleanError(value, fallback) {
        var lines = String(value || "").split("\n")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line.length > 0) return line
        }
        return fallback
    }
}
