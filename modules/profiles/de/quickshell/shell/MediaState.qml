pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    property var activePlayer: null
    readonly property bool available: activePlayer !== null && (title.length > 0 || artist.length > 0)
    readonly property bool playing: activePlayer !== null && Boolean(activePlayer.isPlaying)
    readonly property string player: activePlayer ? String(activePlayer.identity || activePlayer.desktopEntry || "") : ""
    readonly property string artist: activePlayer ? String(activePlayer.trackArtist || "") : ""
    readonly property string title: activePlayer ? String(activePlayer.trackTitle || "") : ""

    Connections {
        target: Mpris.players
        function onValuesChanged() {
            root.selectPlayer();
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.selectPlayer()
    }

    Component.onCompleted: selectPlayer()

    function playerValues() {
        var model = Mpris.players;
        return model && model.values ? model.values : [];
    }

    function selectPlayer() {
        var values = playerValues();
        var selected = null;

        if (activePlayer && activePlayer.isPlaying) {
            for (var i = 0; i < values.length; i++) {
                if (values[i] === activePlayer) {
                    selected = activePlayer;
                    break;
                }
            }
        }

        if (!selected) {
            for (var j = 0; j < values.length; j++) {
                if (values[j] && values[j].isPlaying) {
                    selected = values[j];
                    break;
                }
            }
        }

        if (!selected) {
            for (var k = 0; k < values.length; k++) {
                if (values[k] && values[k] === activePlayer) {
                    selected = values[k];
                    break;
                }
            }
        }

        if (!selected) {
            for (var l = 0; l < values.length; l++) {
                if (values[l] && (values[l].trackTitle || values[l].trackArtist)) {
                    selected = values[l];
                    break;
                }
            }
        }

        activePlayer = selected;
    }

    function command(action) {
        if (!activePlayer || !activePlayer.canControl) return;
        if (action === "previous" && activePlayer.canGoPrevious) activePlayer.previous();
        else if (action === "next" && activePlayer.canGoNext) activePlayer.next();
        else if (action === "play-pause" && activePlayer.canTogglePlaying) activePlayer.togglePlaying();
    }
}
