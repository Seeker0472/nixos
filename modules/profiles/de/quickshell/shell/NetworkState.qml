pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
    id: root

    property string name: "Offline"
    property string type: "none"
    property int signalStrength: 0
    property string interfaceName: ""
    property string address: ""
    property string gateway: ""
    property bool showDetails: false
    property bool wifiEnabled: false
    property var activeNetwork: null
    property string detailsInterface: ""
    property string addressQueryInterface: ""
    property string gatewayQueryInterface: ""

    readonly property bool connected: (root.type !== "none" && root.interfaceName.length > 0) ||
        (root.name !== "Offline" && root.name.length > 0)
    readonly property bool detailsRequested: root.showDetails || (UiState.popupOpen && UiState.popupPage === "network")
    readonly property string label: root.type === "ethernet" ? "Ethernet" : (root.type === "wifi" ? "Wi-Fi" : "Network")

    onDetailsRequestedChanged: {
        if (root.detailsRequested) root.requestDetails()
        else root.clearDetails()
    }

    Process {
        id: addressProcess
        stdout: StdioCollector { onStreamFinished: root.updateAddress(this.text) }
    }

    Process {
        id: gatewayProcess
        stdout: StdioCollector { onStreamFinished: root.updateGateway(this.text) }
    }

    Timer {
        id: refreshTimer
        interval: 100
        repeat: false
        onTriggered: root.refresh(false)
    }

    Connections {
        target: Networking
        function onWifiEnabledChanged() { refreshTimer.restart() }
        function onConnectivityChanged() { refreshTimer.restart() }
    }

    Connections {
        target: Networking.devices
        function onValuesChanged() { refreshTimer.restart() }
    }

    Instantiator {
        model: Networking.devices
        delegate: Connections {
            required property var modelData
            target: modelData
            function onConnectedChanged() { refreshTimer.restart() }
            function onStateChanged() { refreshTimer.restart() }
            function onNameChanged() { refreshTimer.restart() }
            function onAddressChanged() { refreshTimer.restart() }
        }
    }

    Instantiator {
        model: Networking.devices
        delegate: Connections {
            required property var modelData
            target: modelData.networks
            function onValuesChanged() { refreshTimer.restart() }
        }
    }

    Connections {
        target: root.activeNetwork
        ignoreUnknownSignals: true
        function onConnectedChanged() { refreshTimer.restart() }
        function onNameChanged() { refreshTimer.restart() }
        function onStateChanged() { refreshTimer.restart() }
        function onSignalStrengthChanged() { refreshTimer.restart() }
    }

    Component.onCompleted: root.refresh(false)

    function clampPercent(value) {
        var number = Number(value)
        if (isNaN(number)) return 0
        return Math.round(Math.max(0, Math.min(100, number)))
    }

    function resetDisconnected() {
        root.cancelDetailQueries()
        root.activeNetwork = null
        root.type = "none"
        root.name = "Offline"
        root.signalStrength = 0
        root.interfaceName = ""
        root.address = ""
        root.gateway = ""
        root.detailsInterface = ""
        root.addressQueryInterface = ""
        root.gatewayQueryInterface = ""
    }

    function refresh(forceDetails) {
        try {
            if (Networking.backend !== NetworkBackendType.NetworkManager) {
                root.resetDisconnected()
                root.wifiEnabled = false
                return
            }

            root.wifiEnabled = Boolean(Networking.wifiEnabled)
            var model = Networking.devices
            var values = model && model.values ? model.values : []
            var activeDevice = null
            for (var i = 0; i < values.length; i++) {
                if (values[i] && values[i].connected) {
                    activeDevice = values[i]
                    break
                }
            }
            if (!activeDevice) {
                root.resetDisconnected()
                return
            }

            var nextType = activeDevice.type === DeviceType.Wifi ? "wifi"
                : (activeDevice.type === DeviceType.Wired ? "ethernet" : "none")
            var nextInterface = String(activeDevice.name || "")
            var nextName = nextType === "ethernet" ? "Ethernet" : "Network"
            var nextSignal = 0
            var nextActiveNetwork = null
            var networkModel = activeDevice.networks
            var networkValues = networkModel && networkModel.values ? networkModel.values : []
            for (var j = 0; j < networkValues.length; j++) {
                var candidate = networkValues[j]
                if (!candidate || !candidate.connected) continue
                nextActiveNetwork = candidate
                nextName = String(candidate.name || nextName)
                if (nextType === "wifi") nextSignal = root.clampPercent(Number(candidate.signalStrength || 0) * 100)
                break
            }
            if (nextType === "none") nextName = String(activeDevice.name || "Network")

            var selectionChanged = root.activeNetwork !== nextActiveNetwork
            var interfaceChanged = root.interfaceName !== nextInterface
            if (forceDetails || interfaceChanged || selectionChanged) root.cancelDetailQueries()
            if (!root.detailsRequested || forceDetails || interfaceChanged || selectionChanged) {
                root.address = ""
                root.gateway = ""
            }

            root.type = nextType
            root.interfaceName = nextInterface
            root.name = nextName
            root.signalStrength = nextSignal
            root.activeNetwork = nextActiveNetwork
            if (root.detailsRequested) root.requestDetails()
            else root.detailsInterface = ""
        } catch (error) {
            root.resetDisconnected()
            root.wifiEnabled = false
        }
    }

    function cancelDetailQueries() {
        if (addressProcess.running) addressProcess.running = false
        if (gatewayProcess.running) gatewayProcess.running = false
        root.addressQueryInterface = ""
        root.gatewayQueryInterface = ""
    }

    function clearDetails() {
        root.cancelDetailQueries()
        root.address = ""
        root.gateway = ""
        root.detailsInterface = ""
    }

    function requestDetails() {
        if (!root.detailsRequested || !root.connected || root.interfaceName.length === 0) {
            root.clearDetails()
            return
        }
        var iface = root.interfaceName
        root.detailsInterface = iface
        if (!addressProcess.running && root.addressQueryInterface !== iface) {
            root.addressQueryInterface = iface
            addressProcess.exec([Commands.ip, "-j", "-4", "address", "show", "dev", iface])
        }
        if (!gatewayProcess.running && root.gatewayQueryInterface !== iface) {
            root.gatewayQueryInterface = iface
            gatewayProcess.exec([Commands.ip, "-j", "route", "show", "default", "dev", iface])
        }
    }

    function parseJson(text, fallback) {
        try {
            return JSON.parse(text)
        } catch (error) {
            return fallback
        }
    }

    function updateAddress(text) {
        var queriedInterface = root.addressQueryInterface
        root.addressQueryInterface = ""
        if (!root.detailsRequested || queriedInterface.length === 0 || queriedInterface !== root.interfaceName) return
        var payload = root.parseJson(String(text || "").trim(), [])
        if (!Array.isArray(payload) || payload.length === 0) {
            root.address = ""
            return
        }
        var reportedInterface = String((payload[0] && payload[0].ifname) || "")
        if (reportedInterface.length > 0 && reportedInterface !== root.interfaceName) return
        var addresses = payload[0] && Array.isArray(payload[0].addr_info) ? payload[0].addr_info : []
        for (var i = 0; i < addresses.length; i++) {
            var value = addresses[i]
            if (value && value.family === "inet" && value.local) {
                root.address = String(value.local) + (value.prefixlen !== undefined ? "/" + value.prefixlen : "")
                return
            }
        }
        root.address = ""
    }

    function updateGateway(text) {
        var queriedInterface = root.gatewayQueryInterface
        root.gatewayQueryInterface = ""
        if (!root.detailsRequested || queriedInterface.length === 0 || queriedInterface !== root.interfaceName) return
        var payload = root.parseJson(String(text || "").trim(), [])
        if (!Array.isArray(payload)) {
            root.gateway = ""
            return
        }
        for (var i = 0; i < payload.length; i++) {
            if (payload[i] && payload[i].gateway && (!payload[i].dev || String(payload[i].dev) === root.interfaceName)) {
                root.gateway = String(payload[i].gateway)
                return
            }
        }
        root.gateway = ""
    }

    function toggleFormat() {
        root.showDetails = !root.showDetails
    }

    function toggleWifi() {
        Quickshell.execDetached([Commands.nmcli, "radio", "wifi", root.wifiEnabled ? "off" : "on"])
        refreshTimer.restart()
    }

    function connect(nameValue) {
        Quickshell.execDetached([Commands.nmcli, "connection", "up", "id", nameValue])
        refreshTimer.restart()
    }
}
