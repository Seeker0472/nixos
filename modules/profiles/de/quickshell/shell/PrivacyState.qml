pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property bool audioInUse: false
    property bool screenShareActive: false
    property var audioInUseApps: []
    property var screenShareApps: []
    property bool nativeReady: false
    property int fallbackDelay: 30000

    readonly property var trackedObjects: {
        var objects = []
        var groups = Pipewire.linkGroups && Pipewire.linkGroups.values ? Pipewire.linkGroups.values : []
        for (var i = 0; i < groups.length; i++) {
            var group = groups[i]
            if (!group) continue
            if (objects.indexOf(group) < 0) objects.push(group)
            if (group.source && objects.indexOf(group.source) < 0) objects.push(group.source)
            if (group.target && objects.indexOf(group.target) < 0) objects.push(group.target)
        }
        return objects
    }

    PwObjectTracker {
        objects: root.trackedObjects
        onObjectsChanged: nativeRefreshTimer.restart()
    }

    ScriptModel {
        id: trackedModel
        values: root.trackedObjects
    }

    Connections {
        target: Pipewire
        function onReadyChanged() { nativeRefreshTimer.restart() }
    }

    Connections {
        target: Pipewire.linkGroups
        function onValuesChanged() { nativeRefreshTimer.restart() }
    }

    Instantiator {
        model: trackedModel
        delegate: Connections {
            required property var modelData
            target: modelData
            ignoreUnknownSignals: true
            function onStateChanged() { nativeRefreshTimer.restart() }
            function onPropertiesChanged() { nativeRefreshTimer.restart() }
            function onReadyChanged() { nativeRefreshTimer.restart() }
        }
    }

    Process {
        id: fallbackProcess
        command: [Commands.python, Commands.sampler, "--privacy-once", "--pw-dump", Commands.pwDump]
        stdout: StdioCollector { id: fallbackOutput }
        onExited: exitCode => root.finishFallback(exitCode, fallbackOutput.text)
    }

    Timer {
        id: nativeRefreshTimer
        interval: 100
        repeat: false
        onTriggered: root.refreshNative()
    }

    Timer {
        id: fallbackTimer
        interval: root.fallbackDelay
        repeat: false
        onTriggered: root.runFallback()
    }

    Component.onCompleted: root.refreshNative()

    function stringListsEqual(left, right) {
        if (!Array.isArray(left) || !Array.isArray(right) || left.length !== right.length) return false
        for (var i = 0; i < left.length; i++) {
            if (String(left[i]) !== String(right[i])) return false
        }
        return true
    }

    function setState(privacy) {
        var nextAudioApps = Array.isArray(privacy.audioInApps) ? privacy.audioInApps : []
        var nextScreenApps = Array.isArray(privacy.screenShareApps) ? privacy.screenShareApps : []
        var nextAudio = Boolean(privacy.audioIn)
        var nextScreen = Boolean(privacy.screenShare)
        if (root.audioInUse !== nextAudio) root.audioInUse = nextAudio
        if (root.screenShareActive !== nextScreen) root.screenShareActive = nextScreen
        if (!root.stringListsEqual(root.audioInUseApps, nextAudioApps)) root.audioInUseApps = nextAudioApps
        if (!root.stringListsEqual(root.screenShareApps, nextScreenApps)) root.screenShareApps = nextScreenApps
    }

    function refreshNative() {
        if (!Pipewire.ready) {
            root.nativeReady = false
            root.scheduleFallback(false)
            return
        }

        try {
            var audioApps = []
            var screenApps = []
            var groups = Pipewire.linkGroups && Pipewire.linkGroups.values ? Pipewire.linkGroups.values : []
            for (var i = 0; i < groups.length; i++) {
                var group = groups[i]
                if (!group || group.state !== PwLinkState.Active) continue
                var nodes = [group.source, group.target]
                for (var j = 0; j < nodes.length; j++) {
                    var node = nodes[j]
                    if (!node) continue
                    var typeName = String(PwNodeType.toString(node.type))
                    var props = node.properties || {}
                    var nodeName = String(props["node.name"] || node.name || "")
                    var appName = String(props["application.name"] || props["media.name"] ||
                        node.description || node.name || "Unknown")
                    var mediaCategory = String(props["media.category"] || "").toLowerCase()
                    var streamMonitor = String(props["stream.monitor"] || "").toLowerCase()
                    if (mediaCategory === "monitor" || streamMonitor === "true" ||
                            nodeName.toLowerCase() === "cava" || appName.toLowerCase() === "cava") continue

                    var mediaClass = String(props["media.class"] || "")
                    if (typeName === "AudioInStream" || mediaClass === "Stream/Input/Audio") {
                        if (audioApps.indexOf(appName) < 0) audioApps.push(appName)
                    } else if (mediaClass === "Stream/Input/Video") {
                        if (screenApps.indexOf(appName) < 0) screenApps.push(appName)
                    }
                }
            }
            audioApps.sort()
            screenApps.sort()
            root.nativeReady = true
            root.fallbackDelay = 30000
            fallbackTimer.stop()
            root.setState({
                audioIn: audioApps.length > 0,
                screenShare: screenApps.length > 0,
                audioInApps: audioApps,
                screenShareApps: screenApps
            })
        } catch (error) {
            root.nativeReady = false
            root.scheduleFallback(false)
        }
    }

    function scheduleFallback(failed) {
        if (root.nativeReady || fallbackProcess.running) return
        if (failed) root.fallbackDelay = Math.min(root.fallbackDelay * 2, 300000)
        else root.fallbackDelay = Math.max(30000, root.fallbackDelay)
        if (!fallbackTimer.running) fallbackTimer.restart()
    }

    function runFallback() {
        if (!root.nativeReady && !fallbackProcess.running) fallbackProcess.running = true
    }

    function finishFallback(exitCode, output) {
        if (root.nativeReady) return
        var success = false
        if (exitCode === 0) {
            try {
                var sample = JSON.parse(String(output || "").trim())
                if (sample && sample.kind === "privacy") {
                    root.setState(sample)
                    root.fallbackDelay = 30000
                    success = true
                }
            } catch (error) {
                success = false
            }
        }
        root.scheduleFallback(!success)
    }

    function refresh() {
        root.refreshNative()
        if (!root.nativeReady) root.runFallback()
    }

    function tooltip(kind) {
        var names = kind === "screen" ? root.screenShareApps : root.audioInUseApps
        if (!names || names.length === 0) return kind === "screen" ? "Screen sharing active" : "Microphone in use"
        return (kind === "screen" ? "Screen sharing: " : "Microphone: ") + names.join(", ")
    }
}
