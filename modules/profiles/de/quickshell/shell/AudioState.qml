pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property bool showSource: false

    readonly property var defaultSink: Pipewire.defaultAudioSink
    readonly property var defaultSource: Pipewire.defaultAudioSource
    readonly property bool ready: Pipewire.ready && root.defaultSink && root.defaultSink.ready && root.defaultSink.audio
    readonly property bool sourceReady: Pipewire.ready && root.defaultSource && root.defaultSource.ready && root.defaultSource.audio
    readonly property real sinkVolume: root.ready ? root.defaultSink.audio.volume : 0
    readonly property bool sinkMuted: root.ready ? root.defaultSink.audio.muted : false
    readonly property string sinkName: root.ready
        ? (root.defaultSink.description || root.defaultSink.name || "Default output")
        : "Audio unavailable"
    readonly property real sourceVolume: root.sourceReady ? root.defaultSource.audio.volume : 0
    readonly property bool sourceMuted: root.sourceReady ? root.defaultSource.audio.muted : false
    readonly property string sourceName: root.sourceReady
        ? (root.defaultSource.description || root.defaultSource.name || "Default input")
        : "Audio input unavailable"

    PwObjectTracker {
        objects: [root.defaultSink, root.defaultSource]
    }

    function setVolume(value) {
        if (root.ready) root.defaultSink.audio.volume = Math.max(0, Math.min(1, Number(value)))
    }

    function setSourceVolume(value) {
        if (root.sourceReady) root.defaultSource.audio.volume = Math.max(0, Math.min(1, Number(value)))
    }

    function adjustVolume(direction) {
        var delta = Number(direction) * 0.01
        if (root.showSource) root.setSourceVolume(root.sourceVolume + delta)
        else root.setVolume(root.sinkVolume + delta)
    }

    function toggleDisplay() {
        root.showSource = !root.showSource
    }

    function toggleMute() {
        if (root.ready) root.defaultSink.audio.muted = !root.defaultSink.audio.muted
    }

    function toggleSourceMute() {
        if (root.sourceReady) root.defaultSource.audio.muted = !root.defaultSource.audio.muted
    }
}
