import QtQuick 6.0
import QtQuick.Layouts 6.0
import QtQuick.Controls 6.3

Rectangle {
    id: root

    property string page: "overview"
    property var screen: null
    property var parentWindow: null
    readonly property int metricIconWidth: 26
    readonly property int metricBarWidth: 120

    focus: true
    color: Theme.background
    radius: 16
    border.width: 1
    border.color: Theme.surfaceStrong

    Keys.onEscapePressed: event => {
        event.accepted = true
        ShellState.closePopup()
    }

    function pageIndex() {
        switch (root.page) {
        case "system": return 1
        case "audio": return 2
        case "network": return 3
        case "bluetooth": return 4
        case "calendar": return 5
        case "power": return 6
        default: return 0
        }
    }

    function pageTitle() {
        switch (root.page) {
        case "system": return "System"
        case "audio": return "Audio"
        case "network": return "Network"
        case "bluetooth": return "Bluetooth"
        case "calendar": return ShellState.calendarTitle
        case "power": return "Power"
        default: return "Control center"
        }
    }

    function metricAccent(value, normal) {
        var severity = ShellState.metricSeverity(value)
        if (severity === "high") return Theme.danger
        if (severity === "warning") return Theme.warning
        return normal
    }

    function gib(value) {
        return (Number(value || 0) / 1024).toFixed(1) + " GiB"
    }

    function memoryTooltip() {
        return "Memory\n" + gib(ShellState.memoryUsedMiB) + " / " + gib(ShellState.memoryTotalMiB) +
            " (" + ShellState.memoryUsage + "%)\nSwap\n" + gib(ShellState.swapUsedMiB) + " / " + gib(ShellState.swapTotalMiB)
    }

    function batteryDetails() {
        var lines = [ShellState.batteryLevel + "%", ShellState.batteryStatus]
        var time = ShellState.batteryTimeLabel()
        if (time.length > 0) {
            var suffix = ShellState.batteryStatus === "Charging" ? " until full" : (ShellState.batteryStatus === "Discharging" ? " remaining" : "")
            lines.push(time + suffix)
        }
        return lines.join("\n")
    }

    function cpuDetails() {
        var details = []
        if (ShellState.cpuFrequencyMHz > 0) details.push(ShellState.cpuFrequencyMHz + " MHz")
        if (ShellState.cpuCores > 0) details.push(ShellState.cpuCores + " cores")
        details.push("load " + ShellState.loadAverage.toFixed(2))
        return details.join(" · ")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: root.pageTitle()
                    color: Theme.text
                    font.family: "Maple Mono NF CN"
                    font.pixelSize: 17
                    font.weight: Font.DemiBold
                }

                Text {
                    visible: root.page !== "calendar"
                    text: ShellState.focusedTitle
                    color: Theme.muted
                    font.family: "Maple Mono NF CN"
                    font.pixelSize: 10
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                }
            }

            IconButton {
                icon: "×"
                tooltip: "Close"
                onClicked: ShellState.closePopup()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 3

            IconButton { icon: "⌂"; tooltip: "Overview"; selected: root.page === "overview"; onClicked: ShellState.popupPage = "overview" }
            IconButton { icon: "󰒓"; tooltip: "System"; selected: root.page === "system"; onClicked: ShellState.popupPage = "system" }
            IconButton { icon: "󰕾"; tooltip: "Audio"; selected: root.page === "audio"; onClicked: ShellState.popupPage = "audio" }
            IconButton { icon: "󰤨"; tooltip: "Network"; selected: root.page === "network"; onClicked: ShellState.popupPage = "network" }
            IconButton { icon: "󰂯"; tooltip: "Bluetooth"; selected: root.page === "bluetooth"; onClicked: ShellState.popupPage = "bluetooth" }
            IconButton { icon: "󰃭"; tooltip: "Calendar"; selected: root.page === "calendar"; onClicked: ShellState.popupPage = "calendar" }
            IconButton { icon: "󰐥"; tooltip: "Power"; selected: root.page === "power"; onClicked: ShellState.popupPage = "power" }
        }

        StackLayout {
            id: pages
            currentIndex: root.pageIndex()
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            id: cpuCard
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 76
                            radius: Theme.smallRadius
                            color: Theme.backgroundElevated
                            border.width: 1
                            border.color: root.metricAccent(ShellState.cpuUsage, Theme.accent)

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 11
                                spacing: 3
                                Text {
                                    text: "CPU"
                                    color: Theme.muted
                                    font.pixelSize: 10
                                    font.family: "Maple Mono NF CN"
                                }
                                Text {
                                    text: ShellState.cpuUsage + "%"
                                    color: root.metricAccent(ShellState.cpuUsage, Theme.text)
                                    font.pixelSize: 21
                                    font.family: "Maple Mono NF CN"
                                    font.weight: Font.DemiBold
                                }
                                MeterBar {
                                    value: ShellState.cpuUsage / 100
                                    fillColor: root.metricAccent(ShellState.cpuUsage, Theme.accent)
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                }
                            }

                            MouseArea {
                                id: cpuMouse
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                hoverEnabled: true
                                onClicked: ShellState.popupPage = "system"
                            }
                            HoverTooltip {
                                targetItem: cpuCard
                                hovered: cpuMouse.containsMouse
                                text: "CPU usage: " + ShellState.cpuUsage + "%\n" + root.cpuDetails()
                                delay: 500
                            }
                        }

                        Rectangle {
                            id: memoryCard
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 76
                            radius: Theme.smallRadius
                            color: Theme.backgroundElevated
                            border.width: 1
                            border.color: root.metricAccent(ShellState.memoryUsage, Theme.accentAlt)

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 11
                                spacing: 3
                                Text {
                                    text: "Memory"
                                    color: Theme.muted
                                    font.pixelSize: 10
                                    font.family: "Maple Mono NF CN"
                                }
                                Text {
                                    text: ShellState.memoryUsage + "%"
                                    color: root.metricAccent(ShellState.memoryUsage, Theme.text)
                                    font.pixelSize: 21
                                    font.family: "Maple Mono NF CN"
                                    font.weight: Font.DemiBold
                                }
                                MeterBar {
                                    value: ShellState.memoryUsage / 100
                                    fillColor: root.metricAccent(ShellState.memoryUsage, Theme.accentAlt)
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                }
                            }

                            MouseArea {
                                id: memoryMouse
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                hoverEnabled: true
                                onClicked: ShellState.popupPage = "system"
                            }
                            HoverTooltip { targetItem: memoryCard; hovered: memoryMouse.containsMouse; text: root.memoryTooltip(); delay: 500 }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ActionTile {
                            icon: !ShellState.networkConnected ? "󰤭" : (ShellState.networkType === "ethernet" ? "" : "󰤨")
                            title: ShellState.networkConnected ? ShellState.networkLabel : "Offline"
                            subtitle: ShellState.networkConnected ? ShellState.networkName : "No active connection"
                            accent: ShellState.networkConnected ? Theme.accentAlt : Theme.danger
                            Layout.fillWidth: true
                            onClicked: ShellState.popupPage = "network"
                        }
                        ActionTile {
                            icon: ShellState.bluetoothPowered ? "󰂯" : "󰂲"
                            title: "Bluetooth"
                            subtitle: ShellState.bluetoothConnected || "No connected devices"
                            accent: ShellState.bluetoothPowered ? Theme.accentAlt : Theme.subtle
                            Layout.fillWidth: true
                            onClicked: ShellState.popupPage = "bluetooth"
                        }
                    }

                    Rectangle {
                        visible: MediaState.available
                        Layout.fillWidth: true
                        Layout.preferredHeight: 74
                        radius: Theme.smallRadius
                        color: Theme.backgroundElevated

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 11
                            spacing: 8
                            Text { text: "󰎆"; color: Theme.accent; font.pixelSize: 23; font.family: "Maple Mono NF CN" }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { text: MediaState.title; color: Theme.text; font.pixelSize: 12; font.family: "Maple Mono NF CN"; elide: Text.ElideRight; Layout.fillWidth: true }
                                Text { text: MediaState.artist; color: Theme.muted; font.pixelSize: 10; font.family: "Maple Mono NF CN"; elide: Text.ElideRight; Layout.fillWidth: true }
                            }
                            IconButton { icon: "󰒮"; tooltip: "Previous"; onClicked: MediaState.command("previous") }
                            IconButton { icon: MediaState.playing ? "󰏤" : "󰐊"; tooltip: "Play or pause"; onClicked: MediaState.command("play-pause") }
                            IconButton { icon: "󰒭"; tooltip: "Next"; onClicked: MediaState.command("next") }
                        }
                    }

                    ActionTile {
                        icon: "󰕾"
                        title: "Audio"
                        subtitle: ShellState.audioShowSource ? ShellState.sourceName : ShellState.sinkName
                        accent: Theme.accentAlt
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        onClicked: ShellState.popupPage = "audio"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        radius: Theme.smallRadius
                        color: Theme.backgroundElevated

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10

                            Text {
                                text: "Brightness"
                                color: Theme.muted
                                font.family: "Maple Mono NF CN"
                                font.pixelSize: 11
                                Layout.preferredWidth: 66
                            }

                            Text {
                                text: ShellState.brightness + "%"
                                color: Theme.text
                                font.family: "Maple Mono NF CN"
                                font.pixelSize: 12
                                Layout.preferredWidth: 34
                                horizontalAlignment: Text.AlignRight
                            }

                            ValueSlider {
                                value: ShellState.brightness / 100
                                accent: Theme.warning
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                onMoved: ShellState.setBrightness(value)
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ActionTile { icon: "󰌾"; title: "Lock"; subtitle: "Session"; accent: Theme.warning; Layout.fillWidth: true; onClicked: ShellState.run([Commands.swaylock, "-f"]) }
                        ActionTile { icon: "󰐥"; title: "Power"; subtitle: "Session actions"; accent: Theme.danger; Layout.fillWidth: true; onClicked: ShellState.popupPage = "power" }
                    }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 9

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        clip: true
                        radius: Theme.smallRadius
                        color: Theme.backgroundElevated
                        border.width: 1
                        border.color: root.metricAccent(ShellState.cpuUsage, Theme.accent)
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            Text {
                                text: "󰻠"
                                color: root.metricAccent(ShellState.cpuUsage, Theme.accent)
                                font.family: "Maple Mono NF CN"
                                font.pixelSize: 22
                                horizontalAlignment: Text.AlignHCenter
                                Layout.preferredWidth: root.metricIconWidth
                                Layout.minimumWidth: root.metricIconWidth
                                Layout.maximumWidth: root.metricIconWidth
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                spacing: 2
                                Text {
                                    text: "CPU"
                                    color: Theme.text
                                    font.family: "Maple Mono NF CN"
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: ShellState.cpuUsage + "% · " + ShellState.metricSeverity(ShellState.cpuUsage)
                                    color: Theme.muted
                                    font.family: "Maple Mono NF CN"
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                }
                                Text {
                                    text: root.cpuDetails()
                                    color: Theme.subtle
                                    font.family: "Maple Mono NF CN"
                                    font.pixelSize: 9
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                }
                            }
                            MeterBar {
                                value: ShellState.cpuUsage / 100
                                fillColor: root.metricAccent(ShellState.cpuUsage, Theme.accent)
                                Layout.preferredWidth: root.metricBarWidth
                                Layout.minimumWidth: root.metricBarWidth
                                Layout.maximumWidth: root.metricBarWidth
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        clip: true
                        radius: Theme.smallRadius
                        color: Theme.backgroundElevated
                        border.width: 1
                        border.color: root.metricAccent(ShellState.memoryUsage, Theme.accentAlt)
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            Text {
                                text: ""
                                color: root.metricAccent(ShellState.memoryUsage, Theme.accentAlt)
                                font.family: "Maple Mono NF CN"
                                font.pixelSize: 22
                                horizontalAlignment: Text.AlignHCenter
                                Layout.preferredWidth: root.metricIconWidth
                                Layout.minimumWidth: root.metricIconWidth
                                Layout.maximumWidth: root.metricIconWidth
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                spacing: 2
                                Text {
                                    text: "Memory"
                                    color: Theme.text
                                    font.family: "Maple Mono NF CN"
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: gib(ShellState.memoryUsedMiB) + " / " + gib(ShellState.memoryTotalMiB)
                                    color: Theme.muted
                                    font.family: "Maple Mono NF CN"
                                    font.pixelSize: 10
                                }
                                Text {
                                    text: "Swap " + gib(ShellState.swapUsedMiB) + " / " + gib(ShellState.swapTotalMiB)
                                    color: Theme.muted
                                    font.family: "Maple Mono NF CN"
                                    font.pixelSize: 10
                                }
                            }
                            MeterBar {
                                value: ShellState.memoryUsage / 100
                                fillColor: root.metricAccent(ShellState.memoryUsage, Theme.accentAlt)
                                Layout.preferredWidth: root.metricBarWidth
                                Layout.minimumWidth: root.metricBarWidth
                                Layout.maximumWidth: root.metricBarWidth
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            radius: Theme.smallRadius
                            color: Theme.backgroundElevated
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                Text { text: "Temperature"; color: Theme.muted; font.family: "Maple Mono NF CN"; font.pixelSize: 10 }
                                Text { text: ShellState.temperature > 0 ? ShellState.temperature + "°C" : "Unavailable"; color: ShellState.temperature >= 80 ? Theme.danger : Theme.text; font.family: "Maple Mono NF CN"; font.pixelSize: 15 }
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            radius: Theme.smallRadius
                            color: Theme.backgroundElevated
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                Text { text: "Battery"; color: Theme.muted; font.family: "Maple Mono NF CN"; font.pixelSize: 10 }
                                Text { text: ShellState.batteryStatus === "Unknown" ? "Unavailable" : ShellState.batteryLevel + "% · " + ShellState.batteryStatus; color: ShellState.batterySeverity() === "critical" ? Theme.danger : (ShellState.batterySeverity() === "warning" ? Theme.warning : Theme.text); font.family: "Maple Mono NF CN"; font.pixelSize: 13 }
                            }
                        }
                    }

                    ActionTile { icon: "󰆍"; title: "Open btop"; subtitle: "Process, CPU, memory, and swap monitor"; accent: Theme.accentAlt; Layout.fillWidth: true; onClicked: ShellState.run([Commands.btop]) }

                    Rectangle {
                        visible: ShellState.audioInUse || ShellState.screenShareActive || ShellState.idleInhibited || ShellState.isBedtime()
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        radius: Theme.smallRadius
                        color: Theme.backgroundElevated
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Text { text: "Privacy"; color: Theme.muted; font.family: "Maple Mono NF CN"; font.pixelSize: 10 }
                            Text { Layout.fillWidth: true; text: (ShellState.audioInUse ? "󰍬 Mic " : "") + (ShellState.screenShareActive ? "󰖟 Share " : "") + (ShellState.idleInhibited ? " Idle " : "") + (ShellState.isBedtime() ? "󰋣 Bedtime" : ""); color: Theme.warning; font.family: "Maple Mono NF CN"; font.pixelSize: 11; elide: Text.ElideRight }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12
                    Text { text: "Output"; color: Theme.muted; font.pixelSize: 10; font.family: "Maple Mono NF CN" }
                    Text { text: ShellState.sinkName; color: Theme.text; font.pixelSize: 14; font.family: "Maple Mono NF CN"; elide: Text.ElideRight; maximumLineCount: 1; clip: true; Layout.fillWidth: true; Layout.minimumWidth: 0 }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: ShellState.sinkMuted ? "Muted" : Math.round(ShellState.sinkVolume * 100) + "%"; color: Theme.text; font.pixelSize: 12; font.family: "Maple Mono NF CN" }
                        ValueSlider { value: ShellState.sinkVolume; accent: Theme.accentAlt; Layout.fillWidth: true; onMoved: ShellState.setVolume(value) }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        IconButton { icon: ShellState.sinkMuted ? "󰖁" : "󰕾"; label: ShellState.sinkMuted ? "Unmute" : "Mute"; onClicked: ShellState.toggleMute() }
                        IconButton { icon: "󰽴"; label: "Mixer"; onClicked: ShellState.run([Commands.pavucontrol]) }
                        Item { Layout.fillWidth: true }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.surfaceStrong }
                    Text { text: "Input"; color: Theme.muted; font.pixelSize: 10; font.family: "Maple Mono NF CN" }
                    Text { text: ShellState.sourceName; color: Theme.text; font.pixelSize: 14; font.family: "Maple Mono NF CN"; elide: Text.ElideRight; maximumLineCount: 1; clip: true; Layout.fillWidth: true; Layout.minimumWidth: 0 }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: ShellState.sourceMuted ? "Muted" : Math.round(ShellState.sourceVolume * 100) + "%"; color: Theme.text; font.pixelSize: 12; font.family: "Maple Mono NF CN" }
                        ValueSlider { value: ShellState.sourceVolume; accent: Theme.warning; Layout.fillWidth: true; onMoved: ShellState.setSourceVolume(value) }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        IconButton { icon: ShellState.sourceMuted ? "󰍭" : "󰍬"; label: ShellState.sourceMuted ? "Unmute" : "Mute"; onClicked: ShellState.toggleSourceMute() }
                        IconButton { icon: "󰋌"; label: "Show input"; selected: ShellState.audioShowSource; onClicked: ShellState.toggleAudioDisplay() }
                        Item { Layout.fillWidth: true }
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: ShellState.networkConnected ? ShellState.networkName : "Offline"; color: Theme.text; font.pixelSize: 16; font.family: "Maple Mono NF CN"; Layout.fillWidth: true; elide: Text.ElideRight }
                        IconButton { visible: ShellState.networkType === "wifi" || !ShellState.networkConnected; icon: ShellState.wifiEnabled ? "󰖩" : "󰖪"; label: ShellState.wifiEnabled ? "On" : "Off"; selected: ShellState.wifiEnabled; onClicked: ShellState.toggleWifi() }
                    }
                    MeterBar { value: ShellState.networkSignal / 100; fillColor: ShellState.networkConnected ? Theme.accentAlt : Theme.danger; Layout.fillWidth: true }
                    Text { text: ShellState.networkLabel + (ShellState.networkSignal > 0 ? " · " + ShellState.networkSignal + "%" : ""); color: Theme.muted; font.pixelSize: 11; font.family: "Maple Mono NF CN" }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 84
                        radius: Theme.smallRadius
                        color: Theme.backgroundElevated
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 11
                            spacing: 3
                            Text { text: "Interface: " + (ShellState.networkInterface || "-"); color: Theme.text; font.pixelSize: 11; font.family: "Maple Mono NF CN" }
                            Text { text: "Address: " + (ShellState.networkAddress || "-"); color: Theme.muted; font.pixelSize: 10; font.family: "Maple Mono NF CN" }
                            Text { text: "Gateway: " + (ShellState.networkGateway || "-"); color: Theme.muted; font.pixelSize: 10; font.family: "Maple Mono NF CN" }
                        }
                    }
                    ActionTile { icon: "󰖩"; title: "Network connections"; subtitle: "Manage saved networks and VPNs"; accent: Theme.accentAlt; Layout.fillWidth: true; onClicked: ShellState.run([Commands.nmEditor]) }
                    ActionTile { icon: "󰒓"; title: "Refresh status"; subtitle: "Read NetworkManager state again"; accent: Theme.muted; Layout.fillWidth: true; onClicked: ShellState.refreshMetrics() }
                    Item { Layout.fillHeight: true }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 9
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: ShellState.bluetoothPowered ? "Bluetooth ready" : "Bluetooth off"; color: Theme.text; font.pixelSize: 16; font.family: "Maple Mono NF CN"; Layout.fillWidth: true }
                        IconButton { icon: ShellState.bluetoothPowered ? "󰂯" : "󰂲"; label: ShellState.bluetoothPowered ? "On" : "Off"; selected: ShellState.bluetoothPowered; onClicked: ShellState.toggleBluetooth() }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 54
                        radius: Theme.smallRadius
                        color: Theme.backgroundElevated
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2
                            Text { text: ShellState.bluetoothControllerName || "No adapter"; color: Theme.text; font.family: "Maple Mono NF CN"; font.pixelSize: 12 }
                            Text { text: ShellState.bluetoothControllerAddress || "Address unavailable"; color: Theme.muted; font.family: "Maple Mono NF CN"; font.pixelSize: 10 }
                        }
                    }
                    Text { visible: ShellState.bluetoothDevices.length > 0; text: "Connected devices"; color: Theme.muted; font.pixelSize: 10; font.family: "Maple Mono NF CN" }
                    Repeater {
                        model: ShellState.bluetoothDevices
                        delegate: Rectangle {
                            id: deviceCard
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            radius: Theme.smallRadius
                            color: Theme.backgroundElevated
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8
                                Text { text: "󰂱"; color: Theme.accentAlt; font.family: "Maple Mono NF CN"; font.pixelSize: 19 }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text { text: modelData.name; color: Theme.text; font.family: "Maple Mono NF CN"; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                                    Text { text: modelData.address || "Address unavailable"; color: Theme.muted; font.family: "Maple Mono NF CN"; font.pixelSize: 9 }
                                }
                                Text { visible: modelData.battery >= 0; text: Math.round(modelData.battery) + "%"; color: Theme.text; font.family: "Maple Mono NF CN"; font.pixelSize: 11 }
                            }
                            HoverTooltip { targetItem: deviceCard; hovered: deviceMouse.containsMouse; text: modelData.name + "\n" + (modelData.address || "Address unavailable") + (modelData.battery >= 0 ? "\nBattery: " + Math.round(modelData.battery) + "%" : ""); delay: 450 }
                            MouseArea {
                                id: deviceMouse
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                hoverEnabled: true
                                onClicked: ShellState.run([Commands.blueman])
                            }
                        }
                    }
                    Text { visible: ShellState.bluetoothDevices.length === 0; text: "No connected devices"; color: Theme.muted; font.pixelSize: 12; font.family: "Maple Mono NF CN" }
                    ActionTile { icon: "󰂱"; title: "Bluetooth manager"; subtitle: "Pair, connect, and rename devices"; accent: Theme.accentAlt; Layout.fillWidth: true; onClicked: ShellState.run([Commands.blueman]) }
                    ActionTile { icon: "󰒓"; title: "Refresh status"; subtitle: "Read BlueZ state again"; accent: Theme.muted; Layout.fillWidth: true; onClicked: ShellState.refreshNativeServices() }
                    Item { Layout.fillHeight: true }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    RowLayout {
                        Layout.fillWidth: true
                        IconButton { icon: "󰅁"; tooltip: "Previous month"; onClicked: ShellState.shiftCalendar(-1) }
                        Text { text: ShellState.calendarTitle; color: Theme.text; font.family: "Maple Mono NF CN"; font.pixelSize: 15; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                        IconButton { icon: "󰅂"; tooltip: "Next month"; onClicked: ShellState.shiftCalendar(1) }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Repeater {
                            model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                            delegate: Text {
                                required property string modelData
                                text: modelData
                                color: Theme.muted
                                font.pixelSize: 10
                                font.family: "Maple Mono NF CN"
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                    }
                    MonthGrid {
                        id: monthGrid
                        month: ShellState.calendarMonth + 1
                        year: ShellState.calendarYear
                        locale: Qt.locale("en_GB")
                        spacing: 4
                        Layout.fillWidth: true
                        Layout.preferredHeight: 224
                        delegate: Rectangle {
                            required property var model
                            width: monthGrid.width / 7 - 4
                            height: 32
                            radius: 7
                            color: model.today ? Theme.accent : "transparent"
                            border.width: model.month === monthGrid.month && !model.today ? 1 : 0
                            border.color: Theme.surfaceStrong
                            Text { anchors.centerIn: parent; text: model.day; color: model.today ? Theme.background : (model.month === monthGrid.month ? Theme.text : Theme.subtle); font.family: "Maple Mono NF CN"; font.pixelSize: 11 }
                        }
                    }
                    Text { text: "Today: " + Qt.formatDate(ShellState.now, "yyyy-MM-dd"); color: Theme.muted; font.family: "Maple Mono NF CN"; font.pixelSize: 10; Layout.alignment: Qt.AlignHCenter }
                    Item { Layout.fillHeight: true }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    ActionTile { icon: "󰌾"; title: "Lock session"; subtitle: "Keep applications running"; accent: Theme.warning; Layout.fillWidth: true; onClicked: ShellState.run([Commands.swaylock, "-f"]) }
                    ActionTile { icon: "󰤄"; title: "Suspend"; subtitle: "Sleep until you return"; accent: Theme.accentAlt; Layout.fillWidth: true; onClicked: ShellState.run([Commands.systemctl, "suspend"]) }
                    ActionTile { icon: "󰒲"; title: "Hibernate"; subtitle: "Save state to disk"; accent: Theme.accentAlt; Layout.fillWidth: true; onClicked: ShellState.run([Commands.systemctl, "hibernate"]) }
                    ActionTile { icon: "󰜉"; title: "Reboot"; subtitle: "Restart the computer"; accent: Theme.warning; Layout.fillWidth: true; onClicked: ShellState.run([Commands.systemctl, "reboot"]) }
                    ActionTile { icon: "󰐥"; title: "Power off"; subtitle: "Shut down the computer"; accent: Theme.danger; Layout.fillWidth: true; onClicked: ShellState.run([Commands.systemctl, "poweroff"]) }
                }
            }
        }
    }
}
