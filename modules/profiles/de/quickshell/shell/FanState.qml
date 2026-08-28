pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "FanLogic.js" as FanLogic

Singleton {
    id: root

    property bool ready: false
    property bool applying: false
    property bool available: false
    property bool serviceActive: false
    property string controlMode: "unavailable"
    property int temperature: 0
    property var fans: ({
        cpu: { rpm: null, pwm: null, percent: null, enable: null },
        case1: { rpm: null, pwm: null, percent: null, enable: null },
        case2: { rpm: null, pwm: null, percent: null, enable: null }
    })
    property var settings: ({
        version: 1,
        mode: "bios",
        cpu: { zeroRpm: false, minPwm: 96, startTemp: 55, fullTemp: 80 },
        "case": { zeroRpm: false, minPwm: 64, startTemp: 50, fullTemp: 80 }
    })
    property string errorMessage: ""
    property int revision: 0
    property int sentRevision: -1
    property bool dirty: false

    readonly property var cpu: root.fans.cpu || ({})
    readonly property var case1: root.fans.case1 || ({})
    readonly property var case2: root.fans.case2 || ({})
    readonly property var cpuSettings: root.settings.cpu || ({})
    readonly property var caseSettings: root.settings["case"] || ({})
    readonly property bool softwareMode: root.settings.mode === "software"
    readonly property color accentColor: root.controlMode === "software" ? Theme.success
        : (root.controlMode === "bios" ? Theme.accentAlt : Theme.warning)
    readonly property string statusLabel: root.applying ? "Applying"
        : (root.errorMessage.length > 0 ? "Error"
        : (root.controlMode === "software" ? "Software control"
        : (root.controlMode === "bios" ? "BIOS control"
        : (root.controlMode === "degraded" ? "Control mismatch" : "Unavailable"))))
    readonly property string summary: !root.ready ? "Loading fan state"
        : (!root.available ? "Fan sensors unavailable"
        : root.statusLabel + " · CPU " + FanLogic.rpmLabel(root.cpu.rpm)
            + " · Case " + FanLogic.rpmLabel(root.case1.rpm)
            + " / " + FanLogic.rpmLabel(root.case2.rpm))

    Process {
        id: statusProcess
        command: [Commands.fanControl, "status"]
        stdout: StdioCollector { id: statusOutput }
        stderr: StdioCollector { id: statusError }
        onExited: exitCode => root.finishStatus(exitCode, statusOutput.text, statusError.text)
    }

    Process {
        id: applyProcess
        stdout: StdioCollector { id: applyOutput }
        stderr: StdioCollector { id: applyError }
        onExited: exitCode => root.finishApply(exitCode, applyOutput.text, applyError.text)
    }

    Timer {
        id: applyTimer
        interval: 650
        repeat: false
        onTriggered: root.flush()
    }

    Timer {
        interval: 2000
        repeat: true
        running: Commands.fanEnabled
        onTriggered: if (!root.applying && !root.dirty) root.refresh()
    }

    Timer {
        id: recoveryTimer
        interval: 900
        repeat: false
        onTriggered: root.refresh()
    }

    Component.onCompleted: if (Commands.fanEnabled) root.refresh()

    function cleanError(value, fallback) {
        var text = String(value || "").trim()
        if (text.length === 0) return fallback
        try {
            var parsed = JSON.parse(text)
            return String(parsed.error || fallback)
        } catch (error) {
            return text.split("\n")[0]
        }
    }

    function parseResponse(text) {
        var value = JSON.parse(String(text || "").trim())
        if (!value || typeof value.settings !== "object" || typeof value.fans !== "object")
            throw new Error("Incomplete fan controller response")
        return value
    }

    function adopt(value, preserveEdits) {
        root.available = Boolean(value.available)
        root.serviceActive = Boolean(value.serviceActive)
        root.controlMode = String(value.controlMode || "unavailable")
        root.temperature = Number(value.temperature || 0)
        root.fans = value.fans
        if (!preserveEdits) root.settings = value.settings
        root.ready = true
    }

    function refresh() {
        if (!Commands.fanEnabled || statusProcess.running || root.applying || root.dirty) return
        statusProcess.running = true
    }

    function finishStatus(exitCode, output, errorOutput) {
        if (exitCode !== 0) {
            root.errorMessage = root.cleanError(errorOutput || output, "Unable to read fan state")
            root.available = false
            return
        }
        try {
            root.adopt(root.parseResponse(output), false)
            root.errorMessage = ""
        } catch (error) {
            root.errorMessage = "Invalid fan controller response"
            root.available = false
        }
    }

    function markChanged(immediate) {
        root.revision++
        root.dirty = true
        root.errorMessage = ""
        if (immediate) {
            applyTimer.stop()
            root.flush()
        } else {
            applyTimer.restart()
        }
    }

    function setMode(mode) {
        if ((mode !== "bios" && mode !== "software") || root.settings.mode === mode) return
        var next = FanLogic.deepClone(root.settings)
        next.mode = mode
        root.settings = next
        root.markChanged(true)
    }

    function setZeroRpm(group, enabled) {
        var key = group === "cpu" ? "cpu" : "case"
        if (Boolean(root.settings[key].zeroRpm) === Boolean(enabled)) return
        var next = FanLogic.deepClone(root.settings)
        next[key].zeroRpm = Boolean(enabled)
        root.settings = next
        root.markChanged(true)
    }

    function setSetting(group, key, value) {
        var groupKey = group === "cpu" ? "cpu" : "case"
        var next = FanLogic.deepClone(root.settings)
        next[groupKey] = FanLogic.withSetting(next[groupKey], group, key, value)
        root.settings = next
        root.markChanged(false)
    }

    function snapshotPatch() {
        return {
            mode: root.settings.mode,
            cpu: root.settings.cpu,
            "case": root.settings["case"]
        }
    }

    function flush() {
        if (!root.ready || !root.dirty || applyProcess.running) return
        root.dirty = false
        root.applying = true
        root.sentRevision = root.revision
        applyProcess.command = [Commands.fanControl, "apply", JSON.stringify(root.snapshotPatch())]
        applyProcess.running = true
    }

    function finishApply(exitCode, output, errorOutput) {
        root.applying = false
        if (exitCode !== 0) {
            root.errorMessage = root.cleanError(errorOutput || output, "Unable to apply fan settings")
            recoveryTimer.restart()
        } else {
            try {
                root.adopt(root.parseResponse(output), root.revision !== root.sentRevision)
                root.errorMessage = ""
            } catch (error) {
                root.errorMessage = "Invalid fan controller response"
                recoveryTimer.restart()
            }
        }
        if (root.dirty) Qt.callLater(() => root.flush())
        else recoveryTimer.restart()
    }
}
