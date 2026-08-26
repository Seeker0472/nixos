pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

Singleton {
    id: root

    property var workspaces: []
    property var windows: []
    property string focusedTitle: "Desktop"
    property string focusedAppId: ""
    property int focusedWorkspaceIndex: 1

    property int cpuUsage: 0
    property int memoryUsage: 0
    property int memoryUsedMiB: 0
    property int memoryTotalMiB: 0
    property int swapUsedMiB: 0
    property int swapTotalMiB: 0
    property int temperature: 0
    property int batteryLevel: 0
    property string batteryStatus: "Unknown"
    property string batteryTime: ""
    property real batteryTimeToEmpty: 0
    property real batteryTimeToFull: 0
    property bool batteryShowTime: false
    property bool batteryNativeReady: false
    property int brightness: 0
    property string networkName: "Offline"
    property string networkType: "none"
    property int networkSignal: 0
    property string networkInterface: ""
    property string networkAddress: ""
    property string networkGateway: ""
    property bool networkShowDetails: false
    property bool wifiEnabled: false
    property bool bluetoothPowered: false
    property string bluetoothConnected: ""
    property string bluetoothControllerName: ""
    property string bluetoothControllerAddress: ""
    property string bluetoothControllerId: ""
    property bool bluetoothNativeReady: false
    property var bluetoothDevices: []
    property bool bluetoothShowDevice: false
    property bool onBattery: false

    property bool audioInUse: false
    property bool screenShareActive: false
    property var audioInUseApps: []
    property var screenShareApps: []
    property bool idleInhibited: false
    property bool audioShowSource: false
    property bool clockAlternate: false

    property var now: new Date()
    property int calendarMonth: (new Date()).getMonth()
    property int calendarYear: (new Date()).getFullYear()
    property string popupPage: "overview"
    property bool popupOpen: false
    property var popupScreen: null

    readonly property var batteryDevice: UPower.displayDevice
    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    property var defaultSink: Pipewire.defaultAudioSink
    property var defaultSource: Pipewire.defaultAudioSource
    readonly property bool audioReady: Pipewire.ready && defaultSink !== null && defaultSink !== undefined && defaultSink.ready && defaultSink.audio !== null && defaultSink.audio !== undefined
    readonly property bool sourceReady: Pipewire.ready && defaultSource !== null && defaultSource !== undefined && defaultSource.ready && defaultSource.audio !== null && defaultSource.audio !== undefined
    readonly property real sinkVolume: audioReady && defaultSink.audio ? defaultSink.audio.volume : 0
    readonly property bool sinkMuted: audioReady && defaultSink.audio ? defaultSink.audio.muted : false
    readonly property string sinkName: audioReady ? (defaultSink.description || defaultSink.name || "Default output") : "Audio unavailable"
    readonly property real sourceVolume: sourceReady && defaultSource.audio ? defaultSource.audio.volume : 0
    readonly property bool sourceMuted: sourceReady && defaultSource.audio ? defaultSource.audio.muted : false
    readonly property string sourceName: sourceReady ? (defaultSource.description || defaultSource.name || "Default input") : "Audio input unavailable"
    readonly property bool networkConnected: (networkType !== "none" && networkInterface.length > 0) || (networkName !== "Offline" && networkName.length > 0)
    readonly property string networkLabel: networkType === "ethernet" ? "Ethernet" : (networkType === "wifi" ? "Wi-Fi" : "Network")
    readonly property string calendarTitle: Qt.formatDate(new Date(calendarYear, calendarMonth, 1), "MMMM yyyy")

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
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.refreshNativeServices()
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
        refreshNativeServices();
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
        cpuUsage = clampPercent(metrics.cpu);
        memoryUsage = clampPercent(metrics.memory);
        memoryUsedMiB = Number(metrics.memoryUsed || 0);
        memoryTotalMiB = Number(metrics.memoryTotal || 0);
        swapUsedMiB = Number(metrics.swapUsed || 0);
        swapTotalMiB = Number(metrics.swapTotal || 0);
        temperature = Number(metrics.temperature || 0);
        if (!batteryNativeReady) {
            batteryLevel = clampPercent(metrics.battery);
            batteryTime = metrics.batteryTime || "";
        }
        brightness = clampPercent(metrics.brightness);
        if (!batteryNativeReady && metrics.batteryStatus) {
            batteryStatus = metrics.batteryStatus;
        }
        networkType = metrics.networkType || "none";
        networkName = metrics.network || (networkType === "ethernet" ? "Ethernet" : (networkType === "wifi" ? "Wi-Fi" : "Offline"));
        networkSignal = clampPercent(metrics.networkSignal);
        networkInterface = metrics.networkInterface || "";
        networkAddress = metrics.networkAddress || "";
        networkGateway = metrics.networkGateway || "";
        wifiEnabled = Boolean(metrics.wifiEnabled);
        if (!bluetoothNativeReady) {
            bluetoothPowered = Boolean(metrics.bluetoothPowered);
            bluetoothConnected = metrics.bluetoothConnected || "";
            bluetoothControllerName = metrics.bluetoothController || "";
            bluetoothControllerAddress = metrics.bluetoothAddress || "";
        }
        if (bluetoothNativeReady) {
            bluetoothControllerAddress = metrics.bluetoothAddress || bluetoothControllerAddress;
        }
        if (!batteryNativeReady) {
            onBattery = Boolean(metrics.onBattery);
        }
        audioInUse = Boolean(metrics.audioIn);
        screenShareActive = Boolean(metrics.screenShare);
        audioInUseApps = Array.isArray(metrics.audioInApps) ? metrics.audioInApps : [];
        screenShareApps = Array.isArray(metrics.screenShareApps) ? metrics.screenShareApps : [];
    }

    function refreshNativeServices() {
        refreshBattery();
        refreshBluetooth();
    }

    function refreshBattery() {
        var device = UPower.displayDevice;
        if (!device || !device.ready || !device.isPresent || !device.isLaptopBattery) {
            if (batteryNativeReady) {
                batteryLevel = 0;
                batteryStatus = "Unknown";
                batteryTime = "";
                batteryTimeToEmpty = 0;
                batteryTimeToFull = 0;
                onBattery = false;
            }
            batteryNativeReady = false;
            return;
        }

        batteryNativeReady = true;

        var percentage = Number(device.percentage);
        if (!isNaN(percentage)) {
            // Quickshell normalizes UPower's wire percentage to 0.0..1.0.
            batteryLevel = clampPercent(percentage * 100);
        }

        var stateName = "";
        try {
            stateName = String(UPowerDeviceState.toString(device.state));
        } catch (error) {
            stateName = "";
        }
        var compactStateName = stateName.replace(/\s+/g, "");
        if (compactStateName === "FullyCharged") {
            stateName = "Full";
        } else if (compactStateName === "PendingCharge") {
            stateName = "Charging";
        } else if (compactStateName === "PendingDischarge") {
            stateName = "Discharging";
        }
        batteryStatus = stateName.length > 0 ? stateName : "Unknown";

        onBattery = Boolean(UPower.onBattery);
        batteryTimeToEmpty = Math.max(0, Number(device.timeToEmpty || 0));
        batteryTimeToFull = Math.max(0, Number(device.timeToFull || 0));
        var seconds = batteryStatus === "Charging" ? batteryTimeToFull : batteryTimeToEmpty;
        batteryTime = seconds > 0 ? formatDuration(seconds) : "";
    }

    function refreshBluetooth() {
        try {
            var adapter = Bluetooth.defaultAdapter;
            if (!adapter) {
                bluetoothNativeReady = false;
                bluetoothPowered = false;
                bluetoothDevices = [];
                bluetoothConnected = "";
                bluetoothControllerName = "";
                bluetoothControllerAddress = "";
                bluetoothControllerId = "";
                return;
            }
            bluetoothNativeReady = true;
            bluetoothPowered = Boolean(adapter.enabled);
            bluetoothControllerName = String(adapter.name || "Default adapter");
            var adapterId = String(adapter.adapterId || "");
            if (adapterId !== bluetoothControllerId) {
                bluetoothControllerAddress = "";
            }
            bluetoothControllerId = adapterId;

            var model = Bluetooth.devices;
            var values = model && model.values ? model.values : [];
            var connected = [];
            for (var i = 0; i < values.length; i++) {
                var device = values[i];
                if (!device || !device.connected) {
                    continue;
                }
                // BluetoothDevice.battery is normalized to 0.0..1.0 by Quickshell.
                var rawBattery = Number(device.battery);
                connected.push({
                    name: String(device.name || device.deviceName || "Unknown device"),
                    address: String(device.address || ""),
                    battery: device.batteryAvailable && !isNaN(rawBattery) ? clampPercent(rawBattery * 100) : -1
                });
            }
            bluetoothDevices = connected;

            var labels = [];
            for (var j = 0; j < connected.length; j++) {
                var label = connected[j].name;
                if (connected[j].battery >= 0) {
                    label += " " + Math.round(connected[j].battery) + "%";
                }
                labels.push(label);
            }
            bluetoothConnected = labels.join(", ");
        } catch (error) {
            // BlueZ can disappear while a controller is being reset.
            bluetoothNativeReady = false;
            bluetoothPowered = false;
            bluetoothDevices = [];
            bluetoothConnected = "";
            bluetoothControllerName = "";
            bluetoothControllerAddress = "";
            bluetoothControllerId = "";
        }
    }

    function updateWorkspaces(text) {
        var payload = parseJson(text, []);
        var list = unwrap(payload, "Workspaces");
        setWorkspaces(list);
    }

    function sortWorkspaces(list) {
        var sorted = Array.isArray(list) ? list.slice() : [];
        sorted.sort(function(a, b) {
            var aOutput = String((a && a.output) || "");
            var bOutput = String((b && b.output) || "");
            if (aOutput < bOutput) return -1;
            if (aOutput > bOutput) return 1;
            var aIndex = Number((a && a.idx) || 0);
            var bIndex = Number((b && b.idx) || 0);
            if (aIndex !== bIndex) return aIndex - bIndex;
            return Number((a && a.id) || 0) - Number((b && b.id) || 0);
        });
        return sorted;
    }

    function setWorkspaces(list) {
        workspaces = sortWorkspaces(list);
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

    function copyObject(value) {
        var result = {};
        for (var key in value) {
            result[key] = value[key];
        }
        return result;
    }

    function updateWorkspaceUrgency(id, urgent) {
        var next = workspaces.slice();
        for (var i = 0; i < next.length; i++) {
            if (Number(next[i].id) === Number(id)) {
                var workspace = copyObject(next[i]);
                workspace.is_urgent = Boolean(urgent);
                next[i] = workspace;
                setWorkspaces(next);
                return;
            }
        }
        refreshNiri();
    }

    function updateWindowUrgency(id, urgent) {
        var next = windows.slice();
        for (var i = 0; i < next.length; i++) {
            if (Number(next[i].id) === Number(id)) {
                var window = copyObject(next[i]);
                window.is_urgent = Boolean(urgent);
                next[i] = window;
                updateWindows(next);
                return;
            }
        }
        refreshNiri();
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
        if (event.WorkspaceUrgencyChanged !== undefined) {
            var urgencyData = event.WorkspaceUrgencyChanged;
            updateWorkspaceUrgency(urgencyData && urgencyData.id !== undefined ? urgencyData.id : urgencyData, urgencyData && urgencyData.urgent);
            return;
        }
        if (event.WindowsChanged !== undefined) {
            var windowData = event.WindowsChanged;
            updateWindows(windowData && windowData.windows !== undefined ? windowData.windows : windowData);
            return;
        }
        if (event.WindowUrgencyChanged !== undefined) {
            var windowUrgencyData = event.WindowUrgencyChanged;
            updateWindowUrgency(windowUrgencyData && windowUrgencyData.id !== undefined ? windowUrgencyData.id : windowUrgencyData, windowUrgencyData && windowUrgencyData.urgent);
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
            if (openedWindow.is_focused) {
                for (var resetIndex = 0; resetIndex < nextWindows.length; resetIndex++) {
                    nextWindows[resetIndex] = copyObject(nextWindows[resetIndex]);
                    nextWindows[resetIndex].is_focused = false;
                }
            }
            for (var i = 0; i < nextWindows.length; i++) {
                if (Number(nextWindows[i].id) === Number(openedWindow.id)) {
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
            updateWindows(windows.filter(item => Number(item.id) !== Number(closedId)));
            return;
        }
        if (event.WindowFocusChanged !== undefined) {
            var focusData = event.WindowFocusChanged;
            var focusedId = focusData && focusData.id !== undefined ? focusData.id : focusData;
            var nextFocusedWindows = windows.slice();
            var found = false;
            for (var j = 0; j < nextFocusedWindows.length; j++) {
                nextFocusedWindows[j] = copyObject(nextFocusedWindows[j]);
                nextFocusedWindows[j].is_focused = focusedId !== null && Number(nextFocusedWindows[j].id) === Number(focusedId);
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
                if (Number(nextWorkspaces[n].id) === Number(workspaceId)) {
                    targetOutput = nextWorkspaces[n].output;
                    break;
                }
            }
            for (var k = 0; k < nextWorkspaces.length; k++) {
                nextWorkspaces[k] = copyObject(nextWorkspaces[k]);
                if (targetOutput && nextWorkspaces[k].output === targetOutput) {
                    nextWorkspaces[k].is_active = false;
                }
                if (isFocused) {
                    nextWorkspaces[k].is_focused = false;
                }
                if (Number(nextWorkspaces[k].id) === Number(workspaceId)) {
                    nextWorkspaces[k].is_active = true;
                    nextWorkspaces[k].is_focused = isFocused;
                }
            }
            if (targetOutput === null && nextWorkspaces.every(item => Number(item.id) !== Number(workspaceId))) {
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
                if (Number(nextActiveWorkspaces[m].id) === Number(activeData.workspace_id)) {
                    nextActiveWorkspaces[m] = copyObject(nextActiveWorkspaces[m]);
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
    }

    function clampPercent(value) {
        var number = Number(value);
        if (isNaN(number)) return 0;
        return Math.round(Math.max(0, Math.min(100, number)));
    }

    function formatDuration(seconds) {
        var totalMinutes = Math.max(0, Math.round(Number(seconds) / 60));
        var hours = Math.floor(totalMinutes / 60);
        var minutes = totalMinutes % 60;
        if (hours > 0) {
            return hours + "h " + (minutes < 10 ? "0" : "") + minutes + "m";
        }
        return minutes + "m";
    }

    function batterySeverity() {
        if (batteryStatus === "Charging" || batteryStatus === "Full" || (batteryStatus === "Not charging" && !onBattery)) return "normal";
        if (batteryLevel <= 15) return "critical";
        if (batteryLevel <= 40) return "warning";
        return "normal";
    }

    function batteryIcon() {
        if (batteryStatus === "Charging") return "󰂄";
        if (batteryStatus === "Full") return "󰁹";
        if (batteryStatus === "Not charging" && !onBattery) return "";
        if (batteryLevel >= 90) return "󰁹";
        if (batteryLevel >= 70) return "󰂀";
        if (batteryLevel >= 45) return "󰁾";
        if (batteryLevel >= 20) return "󰁼";
        return "󰁺";
    }

    function batteryTimeLabel() {
        if (batteryStatus === "Charging" && batteryTimeToFull > 0) return formatDuration(batteryTimeToFull);
        if (batteryStatus === "Discharging" && batteryTimeToEmpty > 0) return formatDuration(batteryTimeToEmpty);
        return batteryStatus === "Charging" || batteryStatus === "Discharging" ? batteryTime : "";
    }

    function batteryDisplayLabel() {
        if (batteryShowTime) {
            var time = batteryTimeLabel();
            if (time.length > 0) return time;
        }
        return batteryLevel + "%";
    }

    function metricSeverity(value) {
        var number = Number(value);
        if (isNaN(number)) return "normal";
        if (number >= 80) return "high";
        if (number >= 50) return "warning";
        return "normal";
    }

    function workspaceLabel(workspace) {
        return workspace.name || String(workspace.idx || "?");
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

    function isPreferredScreen(screen) {
        return screen !== null && screen !== undefined && preferredScreen() === screen;
    }

    function togglePopup(page, screen) {
        if (popupOpen && popupPage === page && (!screen || popupScreen === screen)) {
            closePopup();
            return;
        }
        if (page === "calendar" && !popupOpen) {
            resetCalendar();
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

    function setSourceVolume(value) {
        if (sourceReady && defaultSource.audio) {
            defaultSource.audio.volume = Math.max(0, Math.min(1, Number(value)));
        }
    }

    function adjustVolume(direction) {
        var delta = Number(direction) * 0.01;
        if (audioShowSource) {
            setSourceVolume(sourceVolume + delta);
        } else {
            setVolume(sinkVolume + delta);
        }
    }

    function toggleAudioDisplay() {
        audioShowSource = !audioShowSource;
    }

    function toggleBluetoothFormat() {
        bluetoothShowDevice = !bluetoothShowDevice;
    }

    function bluetoothDisplayLabel() {
        if (bluetoothShowDevice && bluetoothDevices.length > 0) {
            var first = bluetoothDevices[0];
            return first.name + (bluetoothDevices.length > 1 ? " +" + (bluetoothDevices.length - 1) : "");
        }
        if (bluetoothDevices.length > 0) return String(bluetoothDevices.length);
        if (!bluetoothNativeReady && bluetoothConnected.length > 0) return bluetoothConnected;
        return bluetoothPowered ? "On" : "";
    }

    function toggleNetworkFormat() {
        networkShowDetails = !networkShowDetails;
    }

    function toggleBatteryFormat() {
        batteryShowTime = !batteryShowTime;
    }

    function toggleMute() {
        if (audioReady && defaultSink.audio) {
            defaultSink.audio.muted = !defaultSink.audio.muted;
        }
    }

    function toggleSourceMute() {
        if (sourceReady && defaultSource.audio) {
            defaultSource.audio.muted = !defaultSource.audio.muted;
        }
    }

    function setBrightness(value) {
        var percent = Math.round(Math.max(0, Math.min(100, Number(value) * 100)));
        run([Commands.brightnessctl, "set", String(percent) + "%"]);
        refreshMetrics();
    }

    function brightnessIcon() {
        if (brightness >= 80) return "󰃠";
        if (brightness >= 55) return "󰃟";
        if (brightness >= 30) return "󰃞";
        return "󰃚";
    }

    function adjustBrightness(direction) {
        var suffix = Number(direction) > 0 ? "5%+" : "5%-";
        run([Commands.brightnessctl, "set", suffix]);
        refreshMetrics();
    }

    function toggleWifi() {
        run([Commands.nmcli, "radio", "wifi", wifiEnabled ? "off" : "on"]);
        refreshMetrics();
    }

    function toggleBluetooth() {
        if (bluetoothAdapter) {
            bluetoothAdapter.enabled = !bluetoothPowered;
        } else {
            run([Commands.bluetoothctl, "power", bluetoothPowered ? "off" : "on"]);
        }
        refreshMetrics();
    }

    function connectNetwork(name) {
        run([Commands.nmcli, "connection", "up", "id", name]);
        refreshMetrics();
    }

    function resetCalendar() {
        calendarMonth = now.getMonth();
        calendarYear = now.getFullYear();
    }

    function shiftCalendar(delta) {
        var next = new Date(calendarYear, calendarMonth + Number(delta), 1);
        calendarMonth = next.getMonth();
        calendarYear = next.getFullYear();
    }

    function toggleClockFormat() {
        clockAlternate = !clockAlternate;
    }

    function privacyTooltip(kind) {
        var names = kind === "screen" ? screenShareApps : audioInUseApps;
        if (!names || names.length === 0) return kind === "screen" ? "Screen sharing active" : "Microphone in use";
        return (kind === "screen" ? "Screen sharing: " : "Microphone: ") + names.join(", ");
    }

    function isBedtime() {
        var hour = now.getHours();
        return hour >= 22 || hour < 6;
    }
}
