pragma Singleton

import QtQuick
import Quickshell

// Compatibility facade for existing UI components. State ownership lives in
// the domain singletons; new code should use those singletons directly.
Singleton {
    readonly property string focusedTitle: NiriState.focusedTitle

    readonly property int cpuUsage: SystemState.cpuUsage
    readonly property int cpuFrequencyMHz: SystemState.cpuFrequencyMHz
    readonly property int cpuCores: SystemState.cpuCores
    readonly property real loadAverage: SystemState.loadAverage
    readonly property int memoryUsage: SystemState.memoryUsage
    readonly property int memoryUsedMiB: SystemState.memoryUsedMiB
    readonly property int memoryTotalMiB: SystemState.memoryTotalMiB
    readonly property int swapUsedMiB: SystemState.swapUsedMiB
    readonly property int swapTotalMiB: SystemState.swapTotalMiB
    readonly property int temperature: SystemState.temperature
    readonly property int brightness: SystemState.brightness
    readonly property int batteryLevel: SystemState.batteryLevel
    readonly property string batteryStatus: SystemState.batteryStatus
    readonly property bool onBattery: SystemState.onBattery

    readonly property string networkName: NetworkState.name
    readonly property string networkType: NetworkState.type
    readonly property int networkSignal: NetworkState.signalStrength
    readonly property string networkInterface: NetworkState.interfaceName
    readonly property string networkAddress: NetworkState.address
    readonly property string networkGateway: NetworkState.gateway
    readonly property bool networkShowDetails: NetworkState.showDetails
    readonly property bool networkConnected: NetworkState.connected
    readonly property string networkLabel: NetworkState.label
    readonly property bool wifiEnabled: NetworkState.wifiEnabled

    readonly property bool bluetoothPowered: BluetoothState.powered
    readonly property string bluetoothConnected: BluetoothState.connectedLabel
    readonly property string bluetoothControllerName: BluetoothState.controllerName
    readonly property string bluetoothControllerAddress: BluetoothState.controllerAddress
    readonly property var bluetoothDevices: BluetoothState.devices

    readonly property bool audioReady: AudioState.ready
    readonly property bool sourceReady: AudioState.sourceReady
    readonly property real sinkVolume: AudioState.sinkVolume
    readonly property bool sinkMuted: AudioState.sinkMuted
    readonly property string sinkName: AudioState.sinkName
    readonly property real sourceVolume: AudioState.sourceVolume
    readonly property bool sourceMuted: AudioState.sourceMuted
    readonly property string sourceName: AudioState.sourceName
    readonly property bool audioShowSource: AudioState.showSource

    readonly property bool audioInUse: PrivacyState.audioInUse
    readonly property bool screenShareActive: PrivacyState.screenShareActive
    readonly property bool idleInhibited: UiState.idleInhibited
    readonly property bool clockAlternate: UiState.clockAlternate
    readonly property var now: UiState.now
    readonly property int calendarMonth: UiState.calendarMonth
    readonly property int calendarYear: UiState.calendarYear
    readonly property string calendarTitle: UiState.calendarTitle
    readonly property string popupPage: UiState.popupPage
    readonly property bool popupOpen: UiState.popupOpen
    readonly property var popupScreen: UiState.popupScreen

    function refreshNativeServices() {
        SystemState.refreshBattery()
        NetworkState.refresh(true)
        BluetoothState.refresh()
    }

    function refreshNativeState() {
        refreshNativeServices()
        PrivacyState.refresh()
    }

    function metricSeverity(value) { return SystemState.metricSeverity(value) }
    function batterySeverity() { return SystemState.batterySeverity() }
    function batteryIcon() { return SystemState.batteryIcon() }
    function batteryTimeLabel() { return SystemState.batteryTimeLabel() }
    function batteryDisplayLabel() { return SystemState.batteryDisplayLabel() }
    function brightnessIcon() { return SystemState.brightnessIcon() }
    function setBrightness(value) { SystemState.setBrightness(value) }
    function adjustBrightness(direction) { SystemState.adjustBrightness(direction) }
    function toggleBatteryFormat() { SystemState.toggleBatteryFormat() }

    function setVolume(value) { AudioState.setVolume(value) }
    function setSourceVolume(value) { AudioState.setSourceVolume(value) }
    function adjustVolume(direction) { AudioState.adjustVolume(direction) }
    function toggleAudioDisplay() { AudioState.toggleDisplay() }
    function toggleMute() { AudioState.toggleMute() }
    function toggleSourceMute() { AudioState.toggleSourceMute() }

    function toggleNetworkFormat() { NetworkState.toggleFormat() }
    function toggleWifi() { NetworkState.toggleWifi() }
    function connectNetwork(name) { NetworkState.connect(name) }

    function toggleBluetoothFormat() { BluetoothState.toggleFormat() }
    function toggleBluetooth() { BluetoothState.toggle() }
    function bluetoothDisplayLabel() { return BluetoothState.displayLabel() }

    function workspaceLabel(workspace) { return NiriState.workspaceLabel(workspace) }
    function workspacesFor(outputName) { return NiriState.workspacesFor(outputName) }
    function focusWorkspace(index, outputName) { NiriState.focusWorkspace(index, outputName) }
    function preferredScreen() { return NiriState.preferredScreen() }
    function isPreferredScreen(screen) { return NiriState.isPreferredScreen(screen) }

    function togglePopup(page, screen) { UiState.togglePopup(page, screen) }
    function toggleControlCenter(screen) { UiState.toggleControlCenter(screen) }
    function closePopup() { UiState.closePopup() }
    function shiftCalendar(delta) { UiState.shiftCalendar(delta) }
    function toggleClockFormat() { UiState.toggleClockFormat() }
    function isBedtime() { return UiState.isBedtime() }
    function privacyTooltip(kind) { return PrivacyState.tooltip(kind) }

    function run(command) { Quickshell.execDetached(command) }
}
