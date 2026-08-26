pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property var workspaces: []
    property var windows: []
    property string focusedTitle: "Desktop"
    property string focusedAppId: ""
    property int focusedWorkspaceIndex: 1

    property int cpuUsage: 0
    property int memoryUsage: 0
    property int temperature: 0
    property int batteryLevel: 0
    property string batteryStatus: "Unknown"
    property int brightness: 0
    property string networkName: "Offline"
    property bool wifiEnabled: false
    property bool bluetoothPowered: false
    property string bluetoothConnected: ""
    property bool onBattery: false

    property var now: new Date()
    property var calendarDays: []
    property string popupPage: "overview"
    property bool popupOpen: false
    property var popupScreen: null

    property var defaultSink: Pipewire.defaultAudioSink
    property var defaultSource: Pipewire.defaultAudioSource
    readonly property bool audioReady: Pipewire.ready && defaultSink !== null && defaultSink !== undefined
    readonly property real sinkVolume: audioReady && defaultSink.audio ? defaultSink.audio.volume : 0
    readonly property bool sinkMuted: audioReady && defaultSink.audio ? defaultSink.audio.muted : false
    readonly property string sinkName: audioReady ? (defaultSink.description || defaultSink.name || "Default output") : "Audio unavailable"
    readonly property bool sourceMuted: defaultSource !== null && defaultSource !== undefined && defaultSource.audio ? defaultSource.audio.muted : false

    PwObjectTracker {
        objects: [root.defaultSink, root.defaultSource]
    }

    Process {
        id: metricsProcess
        command: [Commands.metrics]
        stdout: StdioCollector {
            onStreamFinished: root.updateMetrics(this.text)
        }
    }

    Process {
        id: workspacesProcess
        command: [Commands.niri, "msg", "--json", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: root.updateWorkspaces(this.text)
        }
    }

    Process {
        id: focusedWindowProcess
        command: [Commands.niri, "msg", "--json", "focused-window"]
        stdout: StdioCollector {
            onStreamFinished: root.updateFocusedWindow(this.text)
        }
    }

    Process {
        id: niriEventProcess
        command: [Commands.niri, "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: line => root.updateNiriEvent(line)
        }
    }

    Timer {
        interval: 2200
        running: true
        repeat: true
        onTriggered: root.refreshMetrics()
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!niriEventProcess.running) {
                niriEventProcess.running = true;
                root.refreshNiri();
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.updateClock()
    }

    Component.onCompleted: {
        refreshMetrics();
        refreshNiri();
        updateClock();
    }

    function parseJson(text, fallback) {
        try {
            return JSON.parse(text);
        } catch (error) {
            return fallback;
        }
    }

    function unwrap(payload, key) {
        if (payload && payload.Ok && payload.Ok[key] !== undefined) {
            return payload.Ok[key];
        }
        if (payload && payload[key] !== undefined) {
            return payload[key];
        }
        return payload;
    }

    function updateMetrics(text) {
        var metrics = parseJson(text, null);
        if (!metrics) {
            return;
        }
        cpuUsage = Number(metrics.cpu || 0);
        memoryUsage = Number(metrics.memory || 0);
        temperature = Number(metrics.temperature || 0);
        batteryLevel = Number(metrics.battery || 0);
        brightness = Number(metrics.brightness || 0);
        batteryStatus = metrics.batteryStatus || "Unknown";
        networkName = metrics.network || "Offline";
        wifiEnabled = Boolean(metrics.wifiEnabled);
        bluetoothPowered = Boolean(metrics.bluetoothPowered);
        bluetoothConnected = metrics.bluetoothConnected || "";
        onBattery = Boolean(metrics.onBattery);
    }

    function updateWorkspaces(text) {
        var payload = parseJson(text, []);
        var list = unwrap(payload, "Workspaces");
        setWorkspaces(list);
    }

    function setWorkspaces(list) {
        workspaces = Array.isArray(list) ? list : [];
        var hasFocusedWorkspace = false;
        for (var i = 0; i < workspaces.length; i++) {
            if (workspaces[i].is_focused) {
                focusedWorkspaceIndex = Number(workspaces[i].idx || 1);
                hasFocusedWorkspace = true;
                break;
            }
        }
        if (!hasFocusedWorkspace) {
            focusedWorkspaceIndex = 1;
        }
    }

    function updateFocusedWindow(text) {
        var payload = parseJson(text, null);
        var window = unwrap(payload, "FocusedWindow");
        setFocusedWindow(window);
    }

    function setFocusedWindow(window) {
        if (!window || typeof window !== "object") {
            focusedTitle = "Desktop";
            focusedAppId = "";
            return;
        }
        focusedTitle = window.title || "Desktop";
        focusedAppId = window.app_id || "";
    }

    function updateWindows(list) {
        windows = Array.isArray(list) ? list : [];
        updateFocusedFromWindows();
    }

    function updateFocusedFromWindows() {
        for (var i = 0; i < windows.length; i++) {
            if (windows[i].is_focused) {
                setFocusedWindow(windows[i]);
                return;
            }
        }
        setFocusedWindow(null);
    }

    function updateNiriEvent(text) {
        var event = parseJson(text, null);
        if (!event) {
            return;
        }
        if (event.Ok) {
            event = event.Ok;
        }
        if (event.Event) {
            event = event.Event;
        }

        if (event.WorkspacesChanged !== undefined) {
            var workspaceData = event.WorkspacesChanged;
            setWorkspaces(workspaceData && workspaceData.workspaces !== undefined ? workspaceData.workspaces : workspaceData);
            return;
        }
        if (event.WindowsChanged !== undefined) {
            var windowData = event.WindowsChanged;
            updateWindows(windowData && windowData.windows !== undefined ? windowData.windows : windowData);
            return;
        }
        if (event.WindowOpenedOrChanged !== undefined) {
            var openedData = event.WindowOpenedOrChanged;
            var openedWindow = openedData && openedData.window !== undefined ? openedData.window : openedData;
            if (!openedWindow || openedWindow.id === undefined) {
                return;
            }
            var nextWindows = windows.slice();
            var replaced = false;
            for (var i = 0; i < nextWindows.length; i++) {
                if (openedWindow.is_focused) {
                    nextWindows[i].is_focused = false;
                }
                if (nextWindows[i].id === openedWindow.id) {
                    nextWindows[i] = openedWindow;
                    replaced = true;
                    break;
                }
            }
            if (!replaced) {
                nextWindows.push(openedWindow);
            }
            updateWindows(nextWindows);
            return;
        }
        if (event.WindowClosed !== undefined) {
            var closedData = event.WindowClosed;
            var closedId = closedData && closedData.id !== undefined ? closedData.id : closedData;
            updateWindows(windows.filter(item => item.id !== closedId));
            return;
        }
        if (event.WindowFocusChanged !== undefined) {
            var focusData = event.WindowFocusChanged;
            var focusedId = focusData && focusData.id !== undefined ? focusData.id : focusData;
            var nextFocusedWindows = windows.slice();
            var found = false;
            for (var j = 0; j < nextFocusedWindows.length; j++) {
                nextFocusedWindows[j].is_focused = focusedId !== null && nextFocusedWindows[j].id === focusedId;
                if (nextFocusedWindows[j].is_focused) {
                    found = true;
                }
            }
            updateWindows(nextFocusedWindows);
            if (!found && focusedId !== null) {
                focusedWindowProcess.exec(focusedWindowProcess.command);
            }
            return;
        }
        if (event.WorkspaceActivated !== undefined) {
            var activationData = event.WorkspaceActivated;
            if (!activationData) {
                return;
            }
            var workspaceId = activationData.id !== undefined ? activationData.id : activationData;
            var isFocused = activationData.focused === true;
            var nextWorkspaces = workspaces.slice();
            var targetOutput = null;
            for (var n = 0; n < nextWorkspaces.length; n++) {
                if (nextWorkspaces[n].id === workspaceId) {
                    targetOutput = nextWorkspaces[n].output;
                    break;
                }
            }
            for (var k = 0; k < nextWorkspaces.length; k++) {
                if (targetOutput && nextWorkspaces[k].output === targetOutput) {
                    nextWorkspaces[k].is_active = false;
                }
                if (isFocused) {
                    nextWorkspaces[k].is_focused = false;
                }
                if (nextWorkspaces[k].id === workspaceId) {
                    nextWorkspaces[k].is_active = true;
                    nextWorkspaces[k].is_focused = isFocused;
                }
            }
            if (targetOutput === null && nextWorkspaces.every(item => item.id !== workspaceId)) {
                refreshNiri();
                return;
            }
            setWorkspaces(nextWorkspaces);
            return;
        }
        if (event.WorkspaceActiveWindowChanged !== undefined) {
            var activeData = event.WorkspaceActiveWindowChanged;
            if (!activeData) {
                return;
            }
            var nextActiveWorkspaces = workspaces.slice();
            for (var m = 0; m < nextActiveWorkspaces.length; m++) {
                if (nextActiveWorkspaces[m].id === activeData.workspace_id) {
                    nextActiveWorkspaces[m].active_window_id = activeData.active_window_id;
                    break;
                }
            }
            setWorkspaces(nextActiveWorkspaces);
            return;
        }
        if (event.ConfigLoaded && event.ConfigLoaded.failed) {
            refreshNiri();
        }
    }

    function refreshMetrics() {
        metricsProcess.exec([Commands.metrics]);
    }

    function refreshNiri() {
        workspacesProcess.exec(workspacesProcess.command);
        focusedWindowProcess.exec(focusedWindowProcess.command);
    }

    function updateClock() {
        now = new Date();
        rebuildCalendar();
    }

    function rebuildCalendar() {
        var year = now.getFullYear();
        var month = now.getMonth();
        var firstDay = new Date(year, month, 1);
        var offset = (firstDay.getDay() + 6) % 7;
        var daysInMonth = new Date(year, month + 1, 0).getDate();
        var days = [];

        for (var i = 0; i < offset; i++) {
            days.push({ label: "", today: false });
        }
        for (var day = 1; day <= daysInMonth; day++) {
            days.push({ label: String(day), today: day === now.getDate() });
        }
        while (days.length % 7 !== 0) {
            days.push({ label: "", today: false });
        }
        calendarDays = days;
    }

    function workspacesFor(outputName) {
        var result = [];
        for (var i = 0; i < workspaces.length; i++) {
            if (!outputName || !workspaces[i].output || workspaces[i].output === outputName) {
                result.push(workspaces[i]);
            }
        }
        return result.length > 0 ? result : (workspaces.length > 0 ? workspaces : [{idx: 1, is_focused: true, is_active: true}]);
    }

    function workspaceLabel(workspace) {
        return workspace.name || String(workspace.idx || "?");
    }

    function focusWorkspace(index, outputName) {
        Quickshell.execDetached([Commands.focusWorkspace, outputName || "", String(index)]);
        closePopup();
    }

    function preferredScreen() {
        for (var i = 0; i < Quickshell.screens.length; i++) {
            var candidate = Quickshell.screens[i];
            for (var j = 0; j < workspaces.length; j++) {
                if (workspaces[j].is_focused && workspaces[j].output === candidate.name) {
                    return candidate;
                }
            }
        }
        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
    }

    function togglePopup(page, screen) {
        if (popupOpen && popupPage === page && (!screen || popupScreen === screen)) {
            closePopup();
            return;
        }
        popupPage = page || "overview";
        popupScreen = screen || preferredScreen();
        popupOpen = true;
    }

    function toggleControlCenter(screen) {
        if (popupOpen) {
            closePopup();
        } else {
            togglePopup("overview", screen || preferredScreen());
        }
    }

    function closePopup() {
        popupOpen = false;
    }

    function run(command) {
        Quickshell.execDetached(command);
    }

    function setVolume(value) {
        if (audioReady && defaultSink.audio) {
            defaultSink.audio.volume = Math.max(0, Math.min(1, Number(value)));
        }
    }

    function toggleMute() {
        if (audioReady && defaultSink.audio) {
            defaultSink.audio.muted = !defaultSink.audio.muted;
        }
    }

    function setBrightness(value) {
        var percent = Math.round(Math.max(0, Math.min(100, Number(value) * 100)));
        run([Commands.brightnessctl, "set", String(percent) + "%"]);
    }

    function toggleWifi() {
        run([Commands.nmcli, "radio", "wifi", wifiEnabled ? "off" : "on"]);
        refreshMetrics();
    }

    function toggleBluetooth() {
        run([Commands.bluetoothctl, "power", bluetoothPowered ? "off" : "on"]);
        refreshMetrics();
    }

    function connectNetwork(name) {
        run([Commands.nmcli, "connection", "up", "id", name]);
        refreshMetrics();
    }

    function isBedtime() {
        var hour = now.getHours();
        return hour >= 22 || hour < 6;
    }
}
