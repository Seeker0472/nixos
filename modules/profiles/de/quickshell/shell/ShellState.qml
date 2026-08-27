pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

Singleton {
    id: root

    property var workspaces: []
    property var workspacesByOutput: ({})
    property int focusedWindowId: 0
    property string focusedTitle: "Desktop"
    property string focusedAppId: ""
    property int focusedWorkspaceIndex: 1

    property int cpuUsage: 0
    property int cpuFrequencyMHz: 0
    property int cpuCores: 0
    property real loadAverage: 0
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
    property var activeNetwork: null
    property string networkDetailsInterface: ""
    property string networkAddressQueryInterface: ""
    property string networkGatewayQueryInterface: ""
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
    property bool privacyNativeReady: false
    property bool idleInhibited: false
    property bool audioShowSource: false
    property bool clockAlternate: false

    readonly property var now: systemClock.date
    property int calendarMonth: (new Date()).getMonth()
    property int calendarYear: (new Date()).getFullYear()
    property string popupPage: "overview"
    property bool popupOpen: false
    property var popupScreen: null

    readonly property var batteryDevice: UPower.displayDevice
    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property var defaultSink: Pipewire.defaultAudioSink
    readonly property var defaultSource: Pipewire.defaultAudioSource
    readonly property var privacyTrackedObjects: {
        var objects = [];
        var groups = Pipewire.linkGroups && Pipewire.linkGroups.values ? Pipewire.linkGroups.values : [];
        for (var i = 0; i < groups.length; i++) {
            var group = groups[i];
            if (!group) continue;
            if (objects.indexOf(group) < 0) objects.push(group);
            if (group.source && objects.indexOf(group.source) < 0) objects.push(group.source);
            if (group.target && objects.indexOf(group.target) < 0) objects.push(group.target);
        }
        return objects;
    }
    readonly property bool audioReady: Pipewire.ready && defaultSink !== null && defaultSink !== undefined && defaultSink.ready && defaultSink.audio !== null && defaultSink.audio !== undefined
    readonly property bool sourceReady: Pipewire.ready && defaultSource !== null && defaultSource !== undefined && defaultSource.ready && defaultSource.audio !== null && defaultSource.audio !== undefined
    readonly property real sinkVolume: audioReady && defaultSink.audio ? defaultSink.audio.volume : 0
    readonly property bool sinkMuted: audioReady && defaultSink.audio ? defaultSink.audio.muted : false
    readonly property string sinkName: audioReady ? (defaultSink.description || defaultSink.name || "Default output") : "Audio unavailable"
    readonly property real sourceVolume: sourceReady && defaultSource.audio ? defaultSource.audio.volume : 0
    readonly property bool sourceMuted: sourceReady && defaultSource.audio ? defaultSource.audio.muted : false
    readonly property string sourceName: sourceReady ? (defaultSource.description || defaultSource.name || "Default input") : "Audio input unavailable"
    readonly property bool networkConnected: (networkType !== "none" && networkInterface.length > 0) || (networkName !== "Offline" && networkName.length > 0)
    readonly property bool networkDetailsRequested: networkShowDetails || (popupOpen && popupPage === "network")
    readonly property string networkLabel: networkType === "ethernet" ? "Ethernet" : (networkType === "wifi" ? "Wi-Fi" : "Network")
    readonly property string calendarTitle: Qt.formatDate(new Date(calendarYear, calendarMonth, 1), "MMMM yyyy")

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
        enabled: true
    }

    onNetworkDetailsRequestedChanged: {
        if (networkDetailsRequested) {
            requestNetworkDetails();
        } else {
            cancelNetworkDetailQueries();
            networkAddress = "";
            networkGateway = "";
            networkDetailsInterface = "";
        }
    }

    PwObjectTracker {
        objects: [root.defaultSink, root.defaultSource]
    }

    // Link and node interfaces are lazy. Keep only connected privacy endpoints
    // referenced so their state/properties emit native change signals.
    PwObjectTracker {
        objects: root.privacyTrackedObjects
        onObjectsChanged: root.schedulePrivacyRefresh()
    }

    ScriptModel {
        id: privacyObjectsModel
        values: root.privacyTrackedObjects
    }

    Process {
        id: samplerProcess
        command: [Commands.python, "-u", Commands.sampler, "--pw-dump", Commands.pwDump]
        running: true
        stdout: SplitParser {
            onRead: line => root.updateSamplerLine(line)
        }
        onRunningChanged: {
            if (!running) samplerRestartTimer.restart()
        }
    }

    Process {
        id: networkAddressProcess
        stdout: StdioCollector {
            onStreamFinished: root.updateNetworkAddress(this.text)
        }
    }

    Process {
        id: networkGatewayProcess
        stdout: StdioCollector {
            onStreamFinished: root.updateNetworkGateway(this.text)
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
        id: nativeRefreshTimer
        interval: 100
        repeat: false
        onTriggered: root.refreshNativeServices()
    }

    Timer {
        id: privacyRefreshTimer
        interval: 100
        repeat: false
        onTriggered: root.refreshPrivacyFromPipewire()
    }

    Timer {
        id: samplerRestartTimer
        interval: 2000
        repeat: false
        onTriggered: if (!samplerProcess.running) samplerProcess.running = true
    }

    Connections {
        target: UPower
        function onOnBatteryChanged() {
            root.scheduleNativeRefresh();
        }
    }

    Connections {
        target: UPower.devices
        function onValuesChanged() { root.scheduleNativeRefresh(); }
    }

    Connections {
        target: root.batteryDevice
        function onPercentageChanged() { root.scheduleNativeRefresh(); }
        function onStateChanged() { root.scheduleNativeRefresh(); }
        function onTimeToEmptyChanged() { root.scheduleNativeRefresh(); }
        function onTimeToFullChanged() { root.scheduleNativeRefresh(); }
        function onReadyChanged() { root.scheduleNativeRefresh(); }
        function onIsPresentChanged() { root.scheduleNativeRefresh(); }
        function onIsLaptopBatteryChanged() { root.scheduleNativeRefresh(); }
    }

    Connections {
        target: Bluetooth
        function onDefaultAdapterChanged() { root.scheduleNativeRefresh(); }
    }

    Connections {
        target: root.bluetoothAdapter ? root.bluetoothAdapter.devices : null
        function onValuesChanged() { root.scheduleNativeRefresh(); }
    }

    Connections {
        target: root.bluetoothAdapter
        function onEnabledChanged() { root.scheduleNativeRefresh(); }
        function onStateChanged() { root.scheduleNativeRefresh(); }
        function onNameChanged() { root.scheduleNativeRefresh(); }
    }

    Instantiator {
        model: root.bluetoothAdapter ? root.bluetoothAdapter.devices : null
        delegate: Connections {
            required property var modelData
            target: modelData
            function onConnectedChanged() { root.scheduleNativeRefresh(); }
            function onStateChanged() { root.scheduleNativeRefresh(); }
            function onBatteryChanged() { root.scheduleNativeRefresh(); }
            function onBatteryAvailableChanged() { root.scheduleNativeRefresh(); }
            function onAddressChanged() { root.scheduleNativeRefresh(); }
            function onNameChanged() { root.scheduleNativeRefresh(); }
            function onDeviceNameChanged() { root.scheduleNativeRefresh(); }
        }
    }

    Connections {
        target: Networking
        function onWifiEnabledChanged() { root.scheduleNativeRefresh(); }
        function onConnectivityChanged() { root.scheduleNativeRefresh(); }
    }

    Connections {
        target: Networking.devices
        function onValuesChanged() { root.scheduleNativeRefresh(); }
    }

    Instantiator {
        model: Networking.devices
        delegate: Connections {
            required property var modelData
            target: modelData
            function onConnectedChanged() { root.scheduleNativeRefresh(); }
            function onStateChanged() { root.scheduleNativeRefresh(); }
            function onNameChanged() { root.scheduleNativeRefresh(); }
            function onAddressChanged() { root.scheduleNativeRefresh(); }
        }
    }

    Instantiator {
        model: Networking.devices
        delegate: Connections {
            required property var modelData
            target: modelData.networks
            function onValuesChanged() { root.scheduleNativeRefresh(); }
        }
    }

    Connections {
        target: root.activeNetwork
        ignoreUnknownSignals: true
        function onConnectedChanged() { root.scheduleNativeRefresh(); }
        function onNameChanged() { root.scheduleNativeRefresh(); }
        function onStateChanged() { root.scheduleNativeRefresh(); }
        function onSignalStrengthChanged() { root.scheduleNativeRefresh(); }
    }

    Connections {
        target: Pipewire
        function onReadyChanged() { root.schedulePrivacyRefresh(); }
    }

    Connections {
        target: Pipewire.linkGroups
        function onValuesChanged() { root.schedulePrivacyRefresh(); }
    }

    Instantiator {
        model: privacyObjectsModel
        delegate: Connections {
            required property var modelData
            target: modelData
            ignoreUnknownSignals: true
            function onStateChanged() { root.schedulePrivacyRefresh(); }
            function onPropertiesChanged() { root.schedulePrivacyRefresh(); }
            function onReadyChanged() { root.schedulePrivacyRefresh(); }
        }
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
        id: niriInitialFallbackTimer
        interval: 1000
        repeat: false
        onTriggered: if (root.workspaces.length === 0) root.refreshNiri()
    }

    Component.onCompleted: {
        refreshNativeServices();
        refreshPrivacyFromPipewire();
        refreshNiri();
        niriInitialFallbackTimer.start();
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

    function updateSamplerLine(line) {
        var sample = parseJson(String(line || "").trim(), null);
        if (!sample || typeof sample !== "object") return;

        var kind = String(sample.kind || "");
        if (kind === "system") {
            cpuUsage = clampPercent(sample.cpu);
            cpuFrequencyMHz = Math.max(0, Math.round(Number(sample.cpuFrequencyMHz || 0)));
            cpuCores = Math.max(0, Math.round(Number(sample.cpuCores || 0)));
            loadAverage = Math.max(0, Number(sample.loadAverage || 0));
            memoryUsage = clampPercent(sample.memory);
            memoryUsedMiB = Number(sample.memoryUsed || 0);
            memoryTotalMiB = Number(sample.memoryTotal || 0);
            swapUsedMiB = Number(sample.swapUsed || 0);
            swapTotalMiB = Number(sample.swapTotal || 0);
        } else if (kind === "ambient") {
            temperature = Number(sample.temperature || 0);
            brightness = clampPercent(sample.brightness);
        } else if (kind === "privacy" && !privacyNativeReady) {
            setPrivacyState(sample);
        }
    }

    function stringListsEqual(left, right) {
        if (!Array.isArray(left) || !Array.isArray(right) || left.length !== right.length) return false;
        for (var i = 0; i < left.length; i++) {
            if (String(left[i]) !== String(right[i])) return false;
        }
        return true;
    }

    function setPrivacyState(privacy) {
        var nextAudioApps = Array.isArray(privacy.audioInApps) ? privacy.audioInApps : [];
        var nextScreenApps = Array.isArray(privacy.screenShareApps) ? privacy.screenShareApps : [];
        var nextAudio = Boolean(privacy.audioIn);
        var nextScreen = Boolean(privacy.screenShare);
        if (audioInUse !== nextAudio) audioInUse = nextAudio;
        if (screenShareActive !== nextScreen) screenShareActive = nextScreen;
        if (!stringListsEqual(audioInUseApps, nextAudioApps)) audioInUseApps = nextAudioApps;
        if (!stringListsEqual(screenShareApps, nextScreenApps)) screenShareApps = nextScreenApps;
    }

    function refreshNativeServices() {
        refreshBattery();
        refreshBluetooth();
        refreshNetwork();
    }

    function scheduleNativeRefresh() {
        nativeRefreshTimer.restart();
    }

    function schedulePrivacyRefresh() {
        privacyRefreshTimer.restart();
    }

    function refreshNetwork() {
        try {
            if (Networking.backend !== NetworkBackendType.NetworkManager) {
                cancelNetworkDetailQueries();
                activeNetwork = null;
                networkType = "none";
                networkName = "Offline";
                networkSignal = 0;
                networkInterface = "";
                networkAddress = "";
                networkGateway = "";
                networkDetailsInterface = "";
                networkAddressQueryInterface = "";
                networkGatewayQueryInterface = "";
                wifiEnabled = false;
                return;
            }

            wifiEnabled = Boolean(Networking.wifiEnabled);
            var model = Networking.devices;
            var values = model && model.values ? model.values : [];
            var activeDevice = null;
            for (var i = 0; i < values.length; i++) {
                if (values[i] && values[i].connected) {
                    activeDevice = values[i];
                    break;
                }
            }

            if (!activeDevice) {
                cancelNetworkDetailQueries();
                networkType = "none";
                networkName = "Offline";
                networkSignal = 0;
                networkInterface = "";
                networkAddress = "";
                networkGateway = "";
                networkDetailsInterface = "";
                networkAddressQueryInterface = "";
                networkGatewayQueryInterface = "";
                activeNetwork = null;
                return;
            }

            networkType = activeDevice.type === DeviceType.Wifi ? "wifi"
                : (activeDevice.type === DeviceType.Wired ? "ethernet" : "none");
            networkInterface = String(activeDevice.name || "");
            networkSignal = 0;
            networkName = networkType === "ethernet" ? "Ethernet" : "Network";
            var nextActiveNetwork = null;

            var networkModel = activeDevice.networks;
            var networkValues = networkModel && networkModel.values ? networkModel.values : [];
            for (var j = 0; j < networkValues.length; j++) {
                var candidate = networkValues[j];
                if (!candidate || !candidate.connected) continue;
                nextActiveNetwork = candidate;
                networkName = String(candidate.name || networkName);
                if (networkType === "wifi") {
                    networkSignal = clampPercent(Number(candidate.signalStrength || 0) * 100);
                }
                break;
            }

            if (networkType === "none") {
                networkName = String(activeDevice.name || "Network");
            }
            var networkSelectionChanged = activeNetwork !== nextActiveNetwork;
            var networkInterfaceChanged = networkDetailsRequested && networkDetailsInterface !== networkInterface;
            if (networkDetailsRequested && (networkInterfaceChanged || networkSelectionChanged)) {
                cancelNetworkDetailQueries();
            }
            if (!networkDetailsRequested || networkInterfaceChanged || networkSelectionChanged) {
                networkAddress = "";
                networkGateway = "";
            }
            activeNetwork = nextActiveNetwork;
            if (networkDetailsRequested) {
                requestNetworkDetails();
            } else {
                networkDetailsInterface = "";
            }
        } catch (error) {
            cancelNetworkDetailQueries();
            activeNetwork = null;
            networkType = "none";
            networkName = "Offline";
            networkSignal = 0;
            networkInterface = "";
            networkAddress = "";
            networkGateway = "";
            networkDetailsInterface = "";
            networkAddressQueryInterface = "";
            networkGatewayQueryInterface = "";
            wifiEnabled = false;
        }
    }

    function cancelNetworkDetailQueries() {
        if (networkAddressProcess.running) networkAddressProcess.running = false;
        if (networkGatewayProcess.running) networkGatewayProcess.running = false;
        networkAddressQueryInterface = "";
        networkGatewayQueryInterface = "";
    }

    function requestNetworkDetails() {
        if (!networkDetailsRequested || !networkConnected || networkInterface.length === 0) {
            cancelNetworkDetailQueries();
            networkAddress = "";
            networkGateway = "";
            networkDetailsInterface = "";
            return;
        }

        var iface = networkInterface;
        networkDetailsInterface = iface;
        if (networkAddressQueryInterface !== iface) {
            networkAddressQueryInterface = iface;
            networkAddressProcess.exec([Commands.ip, "-j", "-4", "address", "show", "dev", iface]);
        }
        if (networkGatewayQueryInterface !== iface) {
            networkGatewayQueryInterface = iface;
            networkGatewayProcess.exec([Commands.ip, "-j", "route", "show", "default", "dev", iface]);
        }
    }

    function updateNetworkAddress(text) {
        if (!networkDetailsRequested || networkAddressQueryInterface.length === 0 || networkAddressQueryInterface !== networkInterface) return;
        var payload = parseJson(String(text || "").trim(), []);
        if (!Array.isArray(payload) || payload.length === 0) {
            networkAddress = "";
            return;
        }
        var reportedInterface = String(payload[0] && payload[0].ifname || "");
        if (reportedInterface.length > 0 && reportedInterface !== networkInterface) return;
        var addresses = payload[0] && Array.isArray(payload[0].addr_info) ? payload[0].addr_info : [];
        for (var i = 0; i < addresses.length; i++) {
            var address = addresses[i];
            if (address && address.family === "inet" && address.local) {
                networkAddress = String(address.local) + (address.prefixlen !== undefined ? "/" + address.prefixlen : "");
                return;
            }
        }
        networkAddress = "";
    }

    function updateNetworkGateway(text) {
        if (!networkDetailsRequested || networkGatewayQueryInterface.length === 0 || networkGatewayQueryInterface !== networkInterface) return;
        var payload = parseJson(String(text || "").trim(), []);
        if (!Array.isArray(payload)) {
            networkGateway = "";
            return;
        }
        for (var i = 0; i < payload.length; i++) {
            if (payload[i] && payload[i].gateway &&
                    (!payload[i].dev || String(payload[i].dev) === networkInterface)) {
                networkGateway = String(payload[i].gateway);
                return;
            }
        }
        networkGateway = "";
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

    function bluetoothListsEqual(left, right) {
        if (!Array.isArray(left) || !Array.isArray(right) || left.length !== right.length) return false;
        for (var i = 0; i < left.length; i++) {
            if (left[i].id !== right[i].id || left[i].name !== right[i].name ||
                    left[i].address !== right[i].address || left[i].battery !== right[i].battery) {
                return false;
            }
        }
        return true;
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

            var model = adapter.devices;
            var values = model && model.values ? model.values : [];
            var connected = [];
            for (var i = 0; i < values.length; i++) {
                var device = values[i];
                if (!device || !device.connected) {
                    continue;
                }
                // BluetoothDevice.battery is normalized to 0.0..1.0 by Quickshell.
                var rawBattery = Number(device.battery);
                var address = String(device.address || "");
                var name = String(device.name || device.deviceName || "Unknown device");
                connected.push({
                    id: address || name,
                    name: name,
                    address: address,
                    battery: device.batteryAvailable && !isNaN(rawBattery) ? clampPercent(rawBattery * 100) : -1
                });
            }
            if (!bluetoothListsEqual(bluetoothDevices, connected)) {
                bluetoothDevices = connected;
            }

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

    function refreshPrivacyFromPipewire() {
        if (!Pipewire.ready) {
            privacyNativeReady = false;
            setPrivacyState({});
            return;
        }

        try {
            var audioApps = [];
            var screenApps = [];
            var groups = Pipewire.linkGroups && Pipewire.linkGroups.values ? Pipewire.linkGroups.values : [];
            for (var i = 0; i < groups.length; i++) {
                var group = groups[i];
                if (!group || group.state !== PwLinkState.Active) continue;
                var nodes = [group.source, group.target];
                for (var j = 0; j < nodes.length; j++) {
                    var node = nodes[j];
                    if (!node) continue;

                    var typeName = String(PwNodeType.toString(node.type));
                    var props = node.properties || {};
                    var nodeName = String(props["node.name"] || node.name || "");
                    var appName = String(props["application.name"] || props["media.name"] || node.description || node.name || "Unknown");
                    var mediaCategory = String(props["media.category"] || "").toLowerCase();
                    var streamMonitor = String(props["stream.monitor"] || "").toLowerCase();
                    if (mediaCategory === "monitor" || streamMonitor === "true" ||
                            nodeName.toLowerCase() === "cava" || appName.toLowerCase() === "cava") continue;

                    var mediaClass = String(props["media.class"] || "");
                    if (typeName === "AudioInStream" || mediaClass === "Stream/Input/Audio") {
                        if (audioApps.indexOf(appName) < 0) audioApps.push(appName);
                    } else if (mediaClass === "Stream/Input/Video") {
                        if (screenApps.indexOf(appName) < 0) screenApps.push(appName);
                    }
                }
            }
            audioApps.sort();
            screenApps.sort();
            privacyNativeReady = true;
            setPrivacyState({
                audioIn: audioApps.length > 0,
                screenShare: screenApps.length > 0,
                audioInApps: audioApps,
                screenShareApps: screenApps
            });
        } catch (error) {
            privacyNativeReady = false;
            setPrivacyState({});
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
        var sorted = sortWorkspaces(list);
        var grouped = {};
        for (var groupIndex = 0; groupIndex < sorted.length; groupIndex++) {
            var workspace = sorted[groupIndex];
            var output = String((workspace && workspace.output) || "");
            if (!grouped[output]) grouped[output] = [];
            grouped[output].push(workspace);
        }
        workspaces = sorted;
        workspacesByOutput = grouped;
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
            focusedWindowId = 0;
            focusedTitle = "Desktop";
            focusedAppId = "";
            return;
        }
        focusedWindowId = Number(window.id || 0);
        focusedTitle = window.title || "Desktop";
        focusedAppId = window.app_id || "";
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
        // Window urgency is not rendered by the shell. Avoid copying the full
        // window snapshot for an event that has no visible consumer.
        return;
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
            if (openedWindow.is_focused || Number(openedWindow.id) === focusedWindowId) {
                setFocusedWindow(openedWindow);
            }
            return;
        }
        if (event.WindowClosed !== undefined) {
            var closedData = event.WindowClosed;
            var closedId = closedData && closedData.id !== undefined ? closedData.id : closedData;
            if (Number(closedId) === focusedWindowId) {
                focusedWindowId = 0;
                if (!focusedWindowProcess.running) {
                    focusedWindowProcess.exec(focusedWindowProcess.command);
                }
            }
            return;
        }
        if (event.WindowFocusChanged !== undefined) {
            var focusData = event.WindowFocusChanged;
            var focusedId = focusData && focusData.id !== undefined ? focusData.id : focusData;
            focusedWindowId = focusedId === null ? 0 : Number(focusedId || 0);
            if (!focusedWindowProcess.running) {
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

    function refreshNativeState() {
        // Keep the manual refresh action event-driven as well. The resident
        // sampler owns only procfs/sysfs values and continues on its cadence.
        refreshNativeServices();
        refreshPrivacyFromPipewire();
    }

    function refreshNiri() {
        if (!workspacesProcess.running) {
            workspacesProcess.exec(workspacesProcess.command);
        }
        if (!focusedWindowProcess.running) {
            focusedWindowProcess.exec(focusedWindowProcess.command);
        }
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
        var grouped = workspacesByOutput || {};
        if (outputName && grouped[outputName] && grouped[outputName].length > 0) {
            return grouped[outputName];
        }
        return workspaces.length > 0 ? workspaces : [{id: 0, idx: 1, is_focused: true, is_active: true}];
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
        brightness = percent;
        run([Commands.brightnessctl, "set", String(percent) + "%"]);
    }

    function brightnessIcon() {
        if (brightness >= 80) return "󰃠";
        if (brightness >= 55) return "󰃟";
        if (brightness >= 30) return "󰃞";
        return "󰃚";
    }

    function adjustBrightness(direction) {
        var step = Number(direction) > 0 ? 5 : -5;
        brightness = clampPercent(brightness + step);
        var suffix = step > 0 ? "5%+" : "5%-";
        run([Commands.brightnessctl, "set", suffix]);
    }

    function toggleWifi() {
        run([Commands.nmcli, "radio", "wifi", wifiEnabled ? "off" : "on"]);
        refreshNativeState();
    }

    function toggleBluetooth() {
        if (bluetoothAdapter) {
            bluetoothAdapter.enabled = !bluetoothPowered;
        } else {
            run([Commands.bluetoothctl, "power", bluetoothPowered ? "off" : "on"]);
        }
        refreshNativeState();
    }

    function connectNetwork(name) {
        run([Commands.nmcli, "connection", "up", "id", name]);
        refreshNativeState();
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
