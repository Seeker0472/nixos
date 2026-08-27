pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "NiriLogic.js" as NiriLogic

Singleton {
    id: root

    property var workspaces: []
    property var workspacesByOutput: ({})
    property int focusedWindowId: 0
    property string focusedTitle: "Desktop"
    property string focusedAppId: ""
    property int focusedWorkspaceIndex: 1

    Process {
        id: workspacesProcess
        command: [Commands.niri, "msg", "--json", "workspaces"]
        stdout: StdioCollector { onStreamFinished: root.updateWorkspaces(this.text) }
    }

    Process {
        id: focusedWindowProcess
        command: [Commands.niri, "msg", "--json", "focused-window"]
        stdout: StdioCollector { onStreamFinished: root.updateFocusedWindow(this.text) }
    }

    Process {
        id: eventProcess
        command: [Commands.niri, "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser { onRead: line => root.updateEvent(line) }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!eventProcess.running) {
                eventProcess.running = true
                root.refresh()
            }
        }
    }

    Timer {
        id: initialFallbackTimer
        interval: 1000
        repeat: false
        onTriggered: if (root.workspaces.length === 0) root.refresh()
    }

    Component.onCompleted: {
        root.refresh()
        initialFallbackTimer.start()
    }

    function parseJson(text, fallback) {
        try {
            return JSON.parse(text)
        } catch (error) {
            return fallback
        }
    }

    function unwrap(payload, key) {
        if (payload && payload.Ok && payload.Ok[key] !== undefined) return payload.Ok[key]
        if (payload && payload[key] !== undefined) return payload[key]
        return payload
    }

    function refresh() {
        if (!workspacesProcess.running) workspacesProcess.running = true
        if (!focusedWindowProcess.running) focusedWindowProcess.running = true
    }

    function updateWorkspaces(text) {
        var payload = root.parseJson(text, [])
        root.setWorkspaces(root.unwrap(payload, "Workspaces"))
    }

    function sortWorkspaces(list) {
        return NiriLogic.sortWorkspaces(list)
    }

    function setWorkspaces(list) {
        var sorted = root.sortWorkspaces(list)
        var grouped = {}
        for (var groupIndex = 0; groupIndex < sorted.length; groupIndex++) {
            var workspace = sorted[groupIndex]
            var output = String((workspace && workspace.output) || "")
            if (!grouped[output]) grouped[output] = []
            grouped[output].push(workspace)
        }
        root.workspaces = sorted
        root.workspacesByOutput = grouped

        root.focusedWorkspaceIndex = 1
        for (var i = 0; i < sorted.length; i++) {
            if (sorted[i].is_focused) {
                root.focusedWorkspaceIndex = Number(sorted[i].idx || 1)
                break
            }
        }
    }

    function updateFocusedWindow(text) {
        var payload = root.parseJson(text, null)
        root.setFocusedWindow(root.unwrap(payload, "FocusedWindow"))
    }

    function setFocusedWindow(window) {
        if (!window || typeof window !== "object") {
            root.focusedWindowId = 0
            root.focusedTitle = "Desktop"
            root.focusedAppId = ""
            return
        }
        root.focusedWindowId = Number(window.id || 0)
        root.focusedTitle = window.title || "Desktop"
        root.focusedAppId = window.app_id || ""
    }

    function copyObject(value) {
        return NiriLogic.copyObject(value)
    }

    function updateWorkspaceUrgency(id, urgent) {
        var next = root.workspaces.slice()
        for (var i = 0; i < next.length; i++) {
            if (Number(next[i].id) === Number(id)) {
                var workspace = root.copyObject(next[i])
                workspace.is_urgent = Boolean(urgent)
                next[i] = workspace
                root.setWorkspaces(next)
                return
            }
        }
        root.refresh()
    }

    function updateEvent(text) {
        var event = root.parseJson(text, null)
        if (!event) return
        if (event.Ok) event = event.Ok
        if (event.Event) event = event.Event

        if (event.WorkspacesChanged !== undefined) {
            var workspaceData = event.WorkspacesChanged
            root.setWorkspaces(workspaceData && workspaceData.workspaces !== undefined
                ? workspaceData.workspaces : workspaceData)
            return
        }
        if (event.WorkspaceUrgencyChanged !== undefined) {
            var urgencyData = event.WorkspaceUrgencyChanged
            root.updateWorkspaceUrgency(
                urgencyData && urgencyData.id !== undefined ? urgencyData.id : urgencyData,
                urgencyData && urgencyData.urgent
            )
            return
        }
        if (event.WindowUrgencyChanged !== undefined) return

        if (event.WindowOpenedOrChanged !== undefined) {
            var openedData = event.WindowOpenedOrChanged
            var openedWindow = openedData && openedData.window !== undefined ? openedData.window : openedData
            if (openedWindow && openedWindow.id !== undefined &&
                    (openedWindow.is_focused || Number(openedWindow.id) === root.focusedWindowId)) {
                root.setFocusedWindow(openedWindow)
            }
            return
        }
        if (event.WindowClosed !== undefined) {
            var closedData = event.WindowClosed
            var closedId = closedData && closedData.id !== undefined ? closedData.id : closedData
            if (Number(closedId) === root.focusedWindowId) {
                root.focusedWindowId = 0
                if (!focusedWindowProcess.running) focusedWindowProcess.running = true
            }
            return
        }
        if (event.WindowFocusChanged !== undefined) {
            var focusData = event.WindowFocusChanged
            var focusedId = focusData && focusData.id !== undefined ? focusData.id : focusData
            root.focusedWindowId = focusedId === null ? 0 : Number(focusedId || 0)
            if (!focusedWindowProcess.running) focusedWindowProcess.running = true
            return
        }
        if (event.WorkspaceActivated !== undefined) {
            var activationData = event.WorkspaceActivated
            var activation = NiriLogic.activateWorkspace(root.workspaces, activationData)
            if (!activation.found) {
                root.refresh()
                return
            }
            root.setWorkspaces(activation.workspaces)
            return
        }
        if (event.WorkspaceActiveWindowChanged !== undefined) {
            var activeData = event.WorkspaceActiveWindowChanged
            if (!activeData) return
            var nextActiveWorkspaces = root.workspaces.slice()
            for (var m = 0; m < nextActiveWorkspaces.length; m++) {
                if (Number(nextActiveWorkspaces[m].id) === Number(activeData.workspace_id)) {
                    nextActiveWorkspaces[m] = root.copyObject(nextActiveWorkspaces[m])
                    nextActiveWorkspaces[m].active_window_id = activeData.active_window_id
                    break
                }
            }
            root.setWorkspaces(nextActiveWorkspaces)
            return
        }
        if (event.ConfigLoaded && event.ConfigLoaded.failed) root.refresh()
    }

    function workspaceLabel(workspace) {
        return workspace.name || String(workspace.idx || "?")
    }

    function workspacesFor(outputName) {
        var grouped = root.workspacesByOutput || {}
        if (outputName && grouped[outputName] && grouped[outputName].length > 0) return grouped[outputName]
        return root.workspaces.length > 0
            ? root.workspaces
            : [{id: 0, idx: 1, is_focused: true, is_active: true}]
    }

    function focusWorkspace(index, outputName) {
        Quickshell.execDetached([Commands.focusWorkspace, outputName || "", String(index)])
        UiState.closePopup()
    }

    function preferredScreen() {
        for (var i = 0; i < Quickshell.screens.length; i++) {
            var candidate = Quickshell.screens[i]
            for (var j = 0; j < root.workspaces.length; j++) {
                if (root.workspaces[j].is_focused && root.workspaces[j].output === candidate.name) return candidate
            }
        }
        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    }

    function isPreferredScreen(screen) {
        return screen !== null && screen !== undefined && root.preferredScreen() === screen
    }
}
