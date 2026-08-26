import QtQuick 6.0
import QtQuick.Layouts 6.0
import Quickshell
import Quickshell.Services.SystemTray

Item {
    id: root

    property var screen: null
    property var panelWindow: null

    implicitHeight: 52

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.topMargin: 7
        anchors.bottomMargin: 7
        radius: 14
        color: Theme.background
        border.width: 1
        border.color: Theme.surfaceStrong
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 9

        IconButton {
            icon: "◈"
            label: "NIRI"
            tooltip: "Open control center"
            iconColor: Theme.accent
            onClicked: ShellState.toggleControlCenter(root.screen)
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 20
            color: Theme.surfaceStrong
        }

        WorkspaceStrip {
            screen: root.screen
            Layout.preferredWidth: Math.min(350, implicitWidth)
            Layout.minimumWidth: 70
        }

        Text {
            text: ShellState.focusedTitle
            color: Theme.muted
            font.family: "Maple Mono NF CN"
            font.pixelSize: 11
            elide: Text.ElideMiddle
            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Layout.maximumWidth: 420
            verticalAlignment: Text.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        RowLayout {
            spacing: 4

            CavaVisualizer {
                enabled: MediaState.available
                Layout.preferredWidth: 82
                Layout.preferredHeight: 24
            }

            Text {
                visible: MediaState.available
                text: MediaState.title
                color: Theme.muted
                font.family: "Maple Mono NF CN"
                font.pixelSize: 10
                elide: Text.ElideRight
                Layout.maximumWidth: 180
                verticalAlignment: Text.AlignVCenter
            }
        }

        StatusPill {
            icon: ShellState.networkName === "Offline" ? "󰤭" : "󰤨"
            value: ShellState.networkName === "Offline" ? "Offline" : ShellState.networkName
            tooltip: "Network"
            accent: ShellState.networkName === "Offline" ? Theme.danger : Theme.accentAlt
            onClicked: ShellState.togglePopup("network", root.screen)
        }

        StatusPill {
            icon: ShellState.sinkMuted ? "󰖁" : "󰕾"
            value: ShellState.audioReady ? Math.round(ShellState.sinkVolume * 100) + "%" : "Audio"
            tooltip: ShellState.sinkName
            accent: ShellState.sinkMuted ? Theme.danger : Theme.accentAlt
            onClicked: ShellState.togglePopup("audio", root.screen)
        }

        StatusPill {
            visible: ShellState.batteryStatus !== "Unknown"
            icon: ShellState.onBattery ? "󰁹" : "󰂄"
            value: ShellState.batteryLevel + "%"
            tooltip: ShellState.batteryStatus
            accent: ShellState.batteryLevel < 20 ? Theme.danger : Theme.success
            onClicked: ShellState.togglePopup("overview", root.screen)
        }

        StatusPill {
            icon: "󰔛"
            value: Qt.formatTime(ShellState.now, "hh:mm")
            tooltip: Qt.formatDate(ShellState.now, "dddd, MMMM d")
            accent: Theme.accent
            onClicked: ShellState.togglePopup("calendar", root.screen)
        }

        IconButton {
            icon: "󰐥"
            tooltip: "Power"
            iconColor: Theme.muted
            onClicked: ShellState.togglePopup("power", root.screen)
        }

        RowLayout {
            spacing: 2

            Repeater {
                model: SystemTray.items

                delegate: Item {
                    required property var modelData
                    implicitWidth: 24
                    implicitHeight: 28

                    Image {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        source: Quickshell.iconPath(modelData.icon)
                        sourceSize.width: 18
                        sourceSize.height: 18
                        smooth: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (mouse.button === Qt.LeftButton) modelData.activate()
                        onPressed: {
                            if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                                modelData.display(root.panelWindow, mouse.x, root.height)
                            }
                        }
                    }
                }
            }
        }
    }
}
