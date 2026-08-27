pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

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
    property int brightness: 0
    property int batteryLevel: 0
    property string batteryStatus: "Unknown"
    property string batteryTime: ""
    property real batteryTimeToEmpty: 0
    property real batteryTimeToFull: 0
    property bool batteryShowTime: false
    property bool batteryNativeReady: false
    property bool onBattery: false

    readonly property var batteryDevice: UPower.displayDevice

    Process {
        id: samplerProcess
        command: [Commands.python, "-u", Commands.sampler]
        running: true
        stdout: SplitParser { onRead: line => root.updateSamplerLine(line) }
        onRunningChanged: if (!running) samplerRestartTimer.restart()
    }

    Timer {
        id: samplerRestartTimer
        interval: 2000
        repeat: false
        onTriggered: if (!samplerProcess.running) samplerProcess.running = true
    }

    Timer {
        id: batteryRefreshTimer
        interval: 100
        repeat: false
        onTriggered: root.refreshBattery()
    }

    Connections {
        target: UPower
        function onOnBatteryChanged() { batteryRefreshTimer.restart() }
    }

    Connections {
        target: UPower.devices
        function onValuesChanged() { batteryRefreshTimer.restart() }
    }

    Connections {
        target: root.batteryDevice
        function onPercentageChanged() { batteryRefreshTimer.restart() }
        function onStateChanged() { batteryRefreshTimer.restart() }
        function onTimeToEmptyChanged() { batteryRefreshTimer.restart() }
        function onTimeToFullChanged() { batteryRefreshTimer.restart() }
        function onReadyChanged() { batteryRefreshTimer.restart() }
        function onIsPresentChanged() { batteryRefreshTimer.restart() }
        function onIsLaptopBatteryChanged() { batteryRefreshTimer.restart() }
    }

    Component.onCompleted: root.refreshBattery()

    function parseJson(text, fallback) {
        try {
            return JSON.parse(text)
        } catch (error) {
            return fallback
        }
    }

    function updateSamplerLine(line) {
        var sample = root.parseJson(String(line || "").trim(), null)
        if (!sample || typeof sample !== "object") return
        var kind = String(sample.kind || "")
        if (kind === "system") {
            root.cpuUsage = root.clampPercent(sample.cpu)
            root.cpuFrequencyMHz = Math.max(0, Math.round(Number(sample.cpuFrequencyMHz || 0)))
            root.cpuCores = Math.max(0, Math.round(Number(sample.cpuCores || 0)))
            root.loadAverage = Math.max(0, Number(sample.loadAverage || 0))
            root.memoryUsage = root.clampPercent(sample.memory)
            root.memoryUsedMiB = Number(sample.memoryUsed || 0)
            root.memoryTotalMiB = Number(sample.memoryTotal || 0)
            root.swapUsedMiB = Number(sample.swapUsed || 0)
            root.swapTotalMiB = Number(sample.swapTotal || 0)
        } else if (kind === "ambient") {
            root.temperature = Number(sample.temperature || 0)
            root.brightness = root.clampPercent(sample.brightness)
        }
    }

    function refreshBattery() {
        var device = UPower.displayDevice
        if (!device || !device.ready || !device.isPresent || !device.isLaptopBattery) {
            if (root.batteryNativeReady) {
                root.batteryLevel = 0
                root.batteryStatus = "Unknown"
                root.batteryTime = ""
                root.batteryTimeToEmpty = 0
                root.batteryTimeToFull = 0
                root.onBattery = false
            }
            root.batteryNativeReady = false
            return
        }

        root.batteryNativeReady = true
        var percentage = Number(device.percentage)
        if (!isNaN(percentage)) root.batteryLevel = root.clampPercent(percentage * 100)

        var stateName = ""
        try {
            stateName = String(UPowerDeviceState.toString(device.state))
        } catch (error) {
            stateName = ""
        }
        var compactStateName = stateName.replace(/\s+/g, "")
        if (compactStateName === "FullyCharged") stateName = "Full"
        else if (compactStateName === "PendingCharge") stateName = "Charging"
        else if (compactStateName === "PendingDischarge") stateName = "Discharging"
        root.batteryStatus = stateName.length > 0 ? stateName : "Unknown"

        root.onBattery = Boolean(UPower.onBattery)
        root.batteryTimeToEmpty = Math.max(0, Number(device.timeToEmpty || 0))
        root.batteryTimeToFull = Math.max(0, Number(device.timeToFull || 0))
        var seconds = root.batteryStatus === "Charging" ? root.batteryTimeToFull : root.batteryTimeToEmpty
        root.batteryTime = seconds > 0 ? root.formatDuration(seconds) : ""
    }

    function clampPercent(value) {
        var number = Number(value)
        if (isNaN(number)) return 0
        return Math.round(Math.max(0, Math.min(100, number)))
    }

    function formatDuration(seconds) {
        var totalMinutes = Math.max(0, Math.round(Number(seconds) / 60))
        var hours = Math.floor(totalMinutes / 60)
        var minutes = totalMinutes % 60
        if (hours > 0) return hours + "h " + (minutes < 10 ? "0" : "") + minutes + "m"
        return minutes + "m"
    }

    function batterySeverity() {
        if (root.batteryStatus === "Charging" || root.batteryStatus === "Full" ||
                (root.batteryStatus === "Not charging" && !root.onBattery)) return "normal"
        if (root.batteryLevel <= 15) return "critical"
        if (root.batteryLevel <= 40) return "warning"
        return "normal"
    }

    function batteryIcon() {
        if (root.batteryStatus === "Charging") return "󰂄"
        if (root.batteryStatus === "Full") return "󰁹"
        if (root.batteryStatus === "Not charging" && !root.onBattery) return ""
        if (root.batteryLevel >= 90) return "󰁹"
        if (root.batteryLevel >= 70) return "󰂀"
        if (root.batteryLevel >= 45) return "󰁾"
        if (root.batteryLevel >= 20) return "󰁼"
        return "󰁺"
    }

    function batteryTimeLabel() {
        if (root.batteryStatus === "Charging" && root.batteryTimeToFull > 0) return root.formatDuration(root.batteryTimeToFull)
        if (root.batteryStatus === "Discharging" && root.batteryTimeToEmpty > 0) return root.formatDuration(root.batteryTimeToEmpty)
        return root.batteryStatus === "Charging" || root.batteryStatus === "Discharging" ? root.batteryTime : ""
    }

    function batteryDisplayLabel() {
        if (root.batteryShowTime) {
            var time = root.batteryTimeLabel()
            if (time.length > 0) return time
        }
        return root.batteryLevel + "%"
    }

    function toggleBatteryFormat() {
        root.batteryShowTime = !root.batteryShowTime
    }

    function metricSeverity(value) {
        var number = Number(value)
        if (isNaN(number)) return "normal"
        if (number >= 80) return "high"
        if (number >= 50) return "warning"
        return "normal"
    }

    function setBrightness(value) {
        var percent = root.clampPercent(Number(value) * 100)
        root.brightness = percent
        Quickshell.execDetached([Commands.brightnessctl, "set", String(percent) + "%"])
    }

    function brightnessIcon() {
        if (root.brightness >= 80) return "󰃠"
        if (root.brightness >= 55) return "󰃟"
        if (root.brightness >= 30) return "󰃞"
        return "󰃚"
    }

    function adjustBrightness(direction) {
        var step = Number(direction) > 0 ? 5 : -5
        root.brightness = root.clampPercent(root.brightness + step)
        Quickshell.execDetached([Commands.brightnessctl, "set", step > 0 ? "5%+" : "5%-"])
    }
}
