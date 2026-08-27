pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    property bool powered: false
    property string connectedLabel: ""
    property string controllerName: ""
    property string controllerAddress: ""
    property string controllerId: ""
    property bool nativeReady: false
    property var devices: []
    property bool showDevice: false

    readonly property var adapter: Bluetooth.defaultAdapter

    Timer {
        id: refreshTimer
        interval: 100
        repeat: false
        onTriggered: root.refresh()
    }

    Connections {
        target: Bluetooth
        function onDefaultAdapterChanged() { refreshTimer.restart() }
    }

    Connections {
        target: root.adapter ? root.adapter.devices : null
        function onValuesChanged() { refreshTimer.restart() }
    }

    Connections {
        target: root.adapter
        function onEnabledChanged() { refreshTimer.restart() }
        function onStateChanged() { refreshTimer.restart() }
        function onNameChanged() { refreshTimer.restart() }
    }

    Instantiator {
        model: root.adapter ? root.adapter.devices : null
        delegate: Connections {
            required property var modelData
            target: modelData
            function onConnectedChanged() { refreshTimer.restart() }
            function onStateChanged() { refreshTimer.restart() }
            function onBatteryChanged() { refreshTimer.restart() }
            function onBatteryAvailableChanged() { refreshTimer.restart() }
            function onAddressChanged() { refreshTimer.restart() }
            function onNameChanged() { refreshTimer.restart() }
            function onDeviceNameChanged() { refreshTimer.restart() }
        }
    }

    Component.onCompleted: root.refresh()

    function clear() {
        root.nativeReady = false
        root.powered = false
        root.devices = []
        root.connectedLabel = ""
        root.controllerName = ""
        root.controllerAddress = ""
        root.controllerId = ""
    }

    function listsEqual(left, right) {
        if (!Array.isArray(left) || !Array.isArray(right) || left.length !== right.length) return false
        for (var i = 0; i < left.length; i++) {
            if (left[i].id !== right[i].id || left[i].name !== right[i].name ||
                    left[i].address !== right[i].address || left[i].battery !== right[i].battery) return false
        }
        return true
    }

    function clampPercent(value) {
        var number = Number(value)
        if (isNaN(number)) return 0
        return Math.round(Math.max(0, Math.min(100, number)))
    }

    function refresh() {
        try {
            var currentAdapter = Bluetooth.defaultAdapter
            if (!currentAdapter) {
                root.clear()
                return
            }
            root.nativeReady = true
            root.powered = Boolean(currentAdapter.enabled)
            root.controllerName = String(currentAdapter.name || "Default adapter")
            root.controllerId = String(currentAdapter.adapterId || "")

            var model = currentAdapter.devices
            var values = model && model.values ? model.values : []
            var connected = []
            for (var i = 0; i < values.length; i++) {
                var device = values[i]
                if (!device || !device.connected) continue
                var rawBattery = Number(device.battery)
                var address = String(device.address || "")
                var name = String(device.name || device.deviceName || "Unknown device")
                connected.push({
                    id: address || name,
                    name: name,
                    address: address,
                    battery: device.batteryAvailable && !isNaN(rawBattery)
                        ? root.clampPercent(rawBattery * 100) : -1
                })
            }
            if (!root.listsEqual(root.devices, connected)) root.devices = connected

            var labels = []
            for (var j = 0; j < connected.length; j++) {
                var label = connected[j].name
                if (connected[j].battery >= 0) label += " " + Math.round(connected[j].battery) + "%"
                labels.push(label)
            }
            root.connectedLabel = labels.join(", ")
        } catch (error) {
            root.clear()
        }
    }

    function toggle() {
        if (root.adapter) root.adapter.enabled = !root.powered
        else Quickshell.execDetached([Commands.bluetoothctl, "power", root.powered ? "off" : "on"])
        refreshTimer.restart()
    }

    function toggleFormat() {
        root.showDevice = !root.showDevice
    }

    function displayLabel() {
        if (root.showDevice && root.devices.length > 0) {
            var first = root.devices[0]
            return first.name + (root.devices.length > 1 ? " +" + (root.devices.length - 1) : "")
        }
        if (root.devices.length > 0) return String(root.devices.length)
        if (!root.nativeReady && root.connectedLabel.length > 0) return root.connectedLabel
        return root.powered ? "On" : ""
    }
}
