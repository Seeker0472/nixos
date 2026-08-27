pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "RgbLogic.js" as RgbLogic

Singleton {
    id: root

    property bool ready: false
    property bool applying: false
    property bool available: false
    property bool effectsAvailable: false
    property bool power: true
    property int brightness: 100
    property string scene: "spectrum"
    property var scenes: ({})
    property var catalog: []
    property string errorMessage: ""
    property int revision: 0
    property int sentRevision: -1
    property bool dirty: false

    readonly property var currentSceneInfo: root.sceneInfo(root.scene)
    readonly property var currentSettings: root.scenes[root.scene] || ({})
    readonly property var currentParams: root.currentSceneInfo.params || []
    readonly property var previewColors: root.colorsForScene()
    readonly property string sceneName: root.currentSceneInfo.name || "RGB"
    readonly property string summary: !root.ready ? "Loading lighting state"
        : (!root.available ? "OpenRGB unavailable"
        : (!root.power ? "Lighting off" : root.sceneName + " · " + root.brightness + "%"))
    readonly property string statusLabel: root.applying ? "Applying"
        : (root.errorMessage.length > 0 ? "Error" : (!root.available ? "Unavailable" : "Ready"))
    readonly property color accentColor: root.power ? root.colorForScene() : Theme.subtle

    Process {
        id: statusProcess
        command: [Commands.rgbControl, "status"]
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
        interval: 200
        repeat: false
        onTriggered: root.flush()
    }

    Timer {
        id: refreshTimer
        interval: 10000
        repeat: true
        running: Commands.rgbEnabled
        onTriggered: if (!root.applying && !root.dirty) root.refresh()
    }

    Timer {
        id: recoveryTimer
        interval: 900
        repeat: false
        onTriggered: root.refresh()
    }

    Component.onCompleted: if (Commands.rgbEnabled) root.refresh()

    function deepClone(value) {
        return RgbLogic.deepClone(value)
    }

    function sceneInfo(sceneId) {
        return RgbLogic.sceneInfo(root.catalog, sceneId)
    }

    function sceneIcon(sceneId) {
        switch (sceneId) {
        case "solid": return "󰝤"
        case "spectrum": return "󰏘"
        case "breathing": return "󰂏"
        case "aurora": return "󰖚"
        case "rainbow": return "󰯯"
        case "starlight": return "󰓎"
        case "ember": return "󰈸"
        case "lightning": return "󰙾"
        case "audioPulse": return "󰎈"
        case "audioSpectrum": return "󰎆"
        default: return "󰏘"
        }
    }

    function colorForScene() {
        var settings = root.currentSettings
        if (settings.color) return settings.color
        if (Array.isArray(settings.colors) && settings.colors.length > 0) return settings.colors[0]
        if (settings.background) return settings.background
        return Theme.accentAlt
    }

    function colorsForScene() {
        return RgbLogic.colorsForScene(root.currentSettings, root.currentSceneInfo.preview)
    }

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
        if (!value || !Array.isArray(value.catalog) || typeof value.scenes !== "object")
            throw new Error("Incomplete RGB controller response")
        return value
    }

    function adopt(value, preserveEdits) {
        root.available = Boolean(value.available)
        root.effectsAvailable = Boolean(value.effectsAvailable)
        root.catalog = value.catalog
        if (!preserveEdits) {
            root.power = Boolean(value.power)
            root.brightness = Number(value.brightness || 0)
            root.scene = String(value.scene || "spectrum")
            root.scenes = value.scenes
        }
        root.ready = true
    }

    function refresh() {
        if (!Commands.rgbEnabled || statusProcess.running || root.applying || root.dirty) return
        statusProcess.running = true
    }

    function finishStatus(exitCode, output, errorOutput) {
        if (exitCode !== 0) {
            root.errorMessage = root.cleanError(errorOutput || output, "Unable to read lighting state")
            root.available = false
            return
        }
        try {
            root.adopt(root.parseResponse(output), false)
            root.errorMessage = ""
        } catch (error) {
            root.errorMessage = "Invalid RGB controller response"
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

    function setScene(sceneId) {
        if (!root.scenes[sceneId] || root.scene === sceneId) return
        root.scene = sceneId
        root.power = true
        root.markChanged(true)
    }

    function setPower(value) {
        if (root.power === Boolean(value)) return
        root.power = Boolean(value)
        root.markChanged(true)
    }

    function togglePower() {
        root.setPower(!root.power)
    }

    function setBrightness(value) {
        var next = Math.max(0, Math.min(100, Math.round(Number(value))))
        if (next === root.brightness) return
        root.brightness = next
        root.markChanged(false)
    }

    function adjustBrightness(direction) {
        root.setBrightness(root.brightness + (direction > 0 ? 5 : -5))
    }

    function setSetting(key, value) {
        if (!root.scenes[root.scene]) return
        root.scenes = RgbLogic.setSetting(root.scenes, root.scene, key, value)
        root.markChanged(false)
    }

    function setColorAt(key, index, color) {
        root.scenes = RgbLogic.setColorAt(root.scenes, root.scene, key, index, color)
        root.markChanged(false)
    }

    function setColorCount(key, count) {
        root.scenes = RgbLogic.setColorCount(root.scenes, root.scene, key, count)
        root.markChanged(false)
    }

    function resetScene() {
        var info = root.currentSceneInfo
        if (!info || !info.defaults) return
        root.scenes = RgbLogic.resetScene(root.scenes, root.scene, info.defaults)
        root.markChanged(true)
    }

    function snapshotPatch() {
        return {
            scene: root.scene,
            power: root.power,
            brightness: root.brightness,
            scenes: root.scenes
        }
    }

    function flush() {
        if (!root.ready || !root.dirty || applyProcess.running) return
        root.dirty = false
        root.applying = true
        root.sentRevision = root.revision
        applyProcess.command = [Commands.rgbControl, "apply", JSON.stringify(root.snapshotPatch())]
        applyProcess.running = true
    }

    function finishApply(exitCode, output, errorOutput) {
        root.applying = false
        if (exitCode !== 0) {
            root.errorMessage = root.cleanError(errorOutput || output, "Unable to apply lighting scene")
            recoveryTimer.restart()
        } else {
            try {
                var response = root.parseResponse(output)
                root.adopt(response, root.revision !== root.sentRevision)
                root.errorMessage = ""
            } catch (error) {
                root.errorMessage = "Invalid RGB controller response"
                recoveryTimer.restart()
            }
        }
        if (root.dirty) Qt.callLater(() => root.flush())
        else recoveryTimer.restart()
    }
}
