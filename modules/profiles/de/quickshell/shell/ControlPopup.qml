import QtQuick 6.0
import QtQuick.Layouts 6.0
import QtQuick.Controls 6.0

Rectangle {
    id: root

    property string page: "overview"
    property var screen: null
    property var parentWindow: null

    focus: true
    color: Theme.background
    radius: 16
    border.width: 1
    border.color: Theme.surfaceStrong

    Keys.onEscapePressed: event => {
        event.accepted = true;
        ShellState.closePopup();
    }

    function pageIndex() {
        switch (root.page) {
        case "audio": return 1
        case "network": return 2
        case "bluetooth": return 3
        case "calendar": return 4
        case "power": return 5
        default: return 0
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: root.page === "calendar" ? Qt.formatDate(ShellState.now, "MMMM yyyy") : "Control center"
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
            spacing: 4

            IconButton { icon: "⌂"; tooltip: "Overview"; selected: root.page === "overview"; onClicked: ShellState.popupPage = "overview" }
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
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 76
                            radius: Theme.smallRadius
                            color: Theme.backgroundElevated

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 3
                                Text { text: "CPU"; color: Theme.muted; font.pixelSize: 10; font.family: "Maple Mono NF CN" }
                                Text { text: ShellState.cpuUsage + "%"; color: Theme.text; font.pixelSize: 22; font.family: "Maple Mono NF CN"; font.weight: Font.DemiBold }
                                MeterBar { value: ShellState.cpuUsage / 100; fillColor: Theme.accent; Layout.fillWidth: true }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 76
                            radius: Theme.smallRadius
                            color: Theme.backgroundElevated

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 3
                                Text { text: "Memory"; color: Theme.muted; font.pixelSize: 10; font.family: "Maple Mono NF CN" }
                                Text { text: ShellState.memoryUsage + "%"; color: Theme.text; font.pixelSize: 22; font.family: "Maple Mono NF CN"; font.weight: Font.DemiBold }
                                MeterBar { value: ShellState.memoryUsage / 100; fillColor: Theme.accentAlt; Layout.fillWidth: true }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        ActionTile {
                            icon: ShellState.networkName === "Offline" ? "󰤭" : "󰤨"
                            title: ShellState.networkName === "Offline" ? "Offline" : "Wi-Fi"
                            subtitle: ShellState.networkName
                            accent: ShellState.networkName === "Offline" ? Theme.danger : Theme.accentAlt
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
                            anchors.margins: 12
                            spacing: 10
                            Text { text: "󰎆"; color: Theme.accent; font.pixelSize: 24; font.family: "Maple Mono NF CN" }
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

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ActionTile { icon: "󰕾"; title: "Audio"; subtitle: ShellState.sinkName; accent: Theme.accentAlt; Layout.fillWidth: true; onClicked: ShellState.popupPage = "audio" }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            Text { text: "Brightness"; color: Theme.muted; font.pixelSize: 10; font.family: "Maple Mono NF CN" }
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: ShellState.brightness + "%"; color: Theme.text; font.pixelSize: 12; font.family: "Maple Mono NF CN" }
                                ValueSlider { value: ShellState.brightness / 100; accent: Theme.warning; Layout.fillWidth: true; onMoved: ShellState.setBrightness(value) }
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
                    spacing: 16
                    Text { text: "Output"; color: Theme.muted; font.pixelSize: 10; font.family: "Maple Mono NF CN" }
                    Text { text: ShellState.sinkName; color: Theme.text; font.pixelSize: 15; font.family: "Maple Mono NF CN"; elide: Text.ElideRight; Layout.fillWidth: true }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: ShellState.sinkMuted ? "Muted" : Math.round(ShellState.sinkVolume * 100) + "%"; color: Theme.text; font.pixelSize: 12; font.family: "Maple Mono NF CN" }
                        ValueSlider { value: ShellState.sinkVolume; accent: Theme.accentAlt; Layout.fillWidth: true; onMoved: ShellState.setVolume(value) }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        IconButton { icon: ShellState.sinkMuted ? "󰖁" : "󰕾"; label: ShellState.sinkMuted ? "Unmute" : "Mute"; onClicked: ShellState.toggleMute() }
                        IconButton { icon: "󰽴"; label: "Mixer"; onClicked: ShellState.run([Commands.pavucontrol]) }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.surfaceStrong }
                    Text { text: "Input"; color: Theme.muted; font.pixelSize: 10; font.family: "Maple Mono NF CN" }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: ShellState.sourceMuted ? "Microphone muted" : "Microphone active"; color: Theme.text; font.pixelSize: 12; font.family: "Maple Mono NF CN"; Layout.fillWidth: true }
                        IconButton { icon: ShellState.sourceMuted ? "󰍭" : "󰍬"; tooltip: "Toggle microphone"; onClicked: ShellState.run([Commands.wpctl, "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]) }
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 14
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: ShellState.networkName; color: Theme.text; font.pixelSize: 16; font.family: "Maple Mono NF CN"; Layout.fillWidth: true; elide: Text.ElideRight }
                        IconButton { icon: ShellState.wifiEnabled ? "󰖩" : "󰖪"; label: ShellState.wifiEnabled ? "On" : "Off"; selected: ShellState.wifiEnabled; onClicked: ShellState.toggleWifi() }
                    }
                    MeterBar { value: ShellState.networkName === "Offline" ? 0 : 1; fillColor: ShellState.networkName === "Offline" ? Theme.danger : Theme.accentAlt; Layout.fillWidth: true }
                    ActionTile { icon: "󰖩"; title: "Network connections"; subtitle: "Manage saved networks and VPNs"; accent: Theme.accentAlt; Layout.fillWidth: true; onClicked: ShellState.run([Commands.nmEditor]) }
                    ActionTile { icon: "󰒓"; title: "Refresh status"; subtitle: "Read NetworkManager state again"; accent: Theme.muted; Layout.fillWidth: true; onClicked: ShellState.refreshMetrics() }
                    Item { Layout.fillHeight: true }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 14
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: ShellState.bluetoothPowered ? "Bluetooth ready" : "Bluetooth off"; color: Theme.text; font.pixelSize: 16; font.family: "Maple Mono NF CN"; Layout.fillWidth: true }
                        IconButton { icon: ShellState.bluetoothPowered ? "󰂯" : "󰂲"; label: ShellState.bluetoothPowered ? "On" : "Off"; selected: ShellState.bluetoothPowered; onClicked: ShellState.toggleBluetooth() }
                    }
                    Text { text: ShellState.bluetoothConnected || "No connected devices"; color: Theme.muted; font.pixelSize: 12; font.family: "Maple Mono NF CN"; wrapMode: Text.Wrap; Layout.fillWidth: true }
                    ActionTile { icon: "󰂱"; title: "Bluetooth manager"; subtitle: "Pair, connect, and rename devices"; accent: Theme.accentAlt; Layout.fillWidth: true; onClicked: ShellState.run([Commands.blueman]) }
                    ActionTile { icon: "󰒓"; title: "Refresh status"; subtitle: "Read BlueZ state again"; accent: Theme.muted; Layout.fillWidth: true; onClicked: ShellState.refreshMetrics() }
                    Item { Layout.fillHeight: true }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12
                    RowLayout {
                        Layout.fillWidth: true
                        Repeater {
                            model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                            delegate: Text { required property string modelData; text: modelData; color: Theme.muted; font.pixelSize: 10; font.family: "Maple Mono NF CN"; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                        }
                    }
                    GridLayout {
                        columns: 7
                        rowSpacing: 4
                        columnSpacing: 2
                        Layout.fillWidth: true
                        Repeater {
                            model: ShellState.calendarDays
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                radius: 8
                                color: modelData.today ? Theme.accent : "transparent"
                                Text { anchors.centerIn: parent; text: modelData.label; color: modelData.today ? Theme.background : Theme.text; font.pixelSize: 11; font.family: "Maple Mono NF CN" }
                            }
                        }
                    }
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
