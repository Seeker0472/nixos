pragma Singleton

import QtQuick 6.0
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property bool playing: false
    property string player: ""
    property string artist: ""
    property string title: ""

    Process {
        id: metadataProcess
        command: [Commands.playerctl, "metadata", "--format", "{{playerName}}|{{status}}|{{artist}}|{{title}}"]
        stdout: StdioCollector {
            onStreamFinished: root.update(this.text)
        }
    }

    Timer {
        interval: 2500
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()

    function refresh() {
        metadataProcess.exec(metadataProcess.command)
    }

    function update(text) {
        var line = String(text || "").trim()
        if (line.length === 0) {
            available = false
            playing = false
            player = ""
            artist = ""
            title = ""
            return
        }
        var fields = line.split("|")
        player = fields[0] || ""
        playing = (fields[1] || "") === "Playing"
        artist = fields[2] || ""
        title = fields.slice(3).join("|") || ""
        available = title.length > 0 || artist.length > 0
    }

    function command(action) {
        Quickshell.execDetached([Commands.playerctl, action])
        refresh()
    }
}
