pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "FanLogic.js" as FanLogic

FocusScope {
    id: root

    focus: visible
    clip: true

    onVisibleChanged: if (visible) FanState.refresh()

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            spacing: 5

            Repeater {
                model: [
                    { key: "software", label: "Software", icon: "󰈐" },
                    { key: "bios", label: "BIOS", icon: "󰒓" }
                ]
                delegate: Rectangle {
                    id: modeChoice
                    required property var modelData
                    readonly property bool selected: FanState.settings.mode === modelData.key
                    readonly property bool choiceEnabled: FanState.ready && !FanState.applying
                        && (modelData.key === "bios" || FanState.available)
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    activeFocusOnTab: true
                    Accessible.role: Accessible.RadioButton
                    Accessible.name: modelData.label + " fan control"
                    Accessible.checked: selected
                    radius: Theme.smallRadius
                    color: selected ? Theme.tint(FanState.accentColor, 0.16)
                        : (modeMouse.containsMouse || activeFocus ? Theme.surface : Theme.backgroundElevated)
                    border.width: activeFocus ? 1 : 0
                    border.color: FanState.accentColor
                    opacity: choiceEnabled ? 1 : 0.45

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: modeChoice.modelData.icon; color: modeChoice.selected ? FanState.accentColor : Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 16 }
                        Text { text: modeChoice.modelData.label; color: modeChoice.selected ? Theme.text : Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.bodyFontSize }
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                            event.accepted = true
                            FanState.setMode(modeChoice.modelData.key)
                        }
                    }
                    Accessible.onPressAction: FanState.setMode(modeChoice.modelData.key)
                    MouseArea {
                        id: modeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: modeChoice.choiceEnabled
                        onPressed: modeChoice.forceActiveFocus(Qt.MouseFocusReason)
                        onClicked: FanState.setMode(modeChoice.modelData.key)
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 76
                Layout.preferredHeight: 32
                radius: Theme.smallRadius
                color: Theme.tint(FanState.temperature >= 80 ? Theme.danger : Theme.accentAlt, 0.12)
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "󰔏"; color: FanState.temperature >= 80 ? Theme.danger : Theme.accentAlt; font.family: Theme.fontFamily; font.pixelSize: 15 }
                    Text { text: FanState.temperature > 0 ? FanState.temperature + "°C" : "--°C"; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.smallFontSize }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            spacing: 6

            Repeater {
                model: [
                    { label: "CPU", rpm: FanState.cpu.rpm, percent: FanState.cpu.percent },
                    { label: "Case 1", rpm: FanState.case1.rpm, percent: FanState.case1.percent },
                    { label: "Case 2", rpm: FanState.case2.rpm, percent: FanState.case2.percent }
                ]
                delegate: Rectangle {
                    id: rpmTile
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 58
                    radius: Theme.smallRadius
                    color: Theme.backgroundElevated
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1
                        Text { text: rpmTile.modelData.label; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; Layout.alignment: Qt.AlignHCenter }
                        Text { text: FanLogic.rpmLabel(rpmTile.modelData.rpm); color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; Layout.alignment: Qt.AlignHCenter }
                        Text { text: rpmTile.modelData.percent === null || rpmTile.modelData.percent === undefined ? "--%" : rpmTile.modelData.percent + "%"; color: Theme.subtle; font.family: Theme.fontFamily; font.pixelSize: 9; Layout.alignment: Qt.AlignHCenter }
                    }
                }
            }
        }

        Text {
            visible: FanState.errorMessage.length > 0
            text: FanState.errorMessage
            color: Theme.danger
            font.family: Theme.fontFamily
            font.pixelSize: Theme.smallFontSize
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 14 : 0
        }

        Flickable {
            id: settingsFlickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: controls.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            ColumnLayout {
                id: controls
                width: settingsFlickable.width - (settingsFlickable.contentHeight > settingsFlickable.height ? 7 : 0)
                spacing: 8

                FanCurveControl {
                    group: "cpu"
                    title: "CPU fan"
                    icon: "󰍛"
                    rpmSummary: FanLogic.rpmLabel(FanState.cpu.rpm)
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.surface
                }

                FanCurveControl {
                    group: "case"
                    title: "Case fans"
                    icon: "󰈐"
                    rpmSummary: FanLogic.rpmLabel(FanState.case1.rpm) + " / " + FanLogic.rpmLabel(FanState.case2.rpm)
                    Layout.fillWidth: true
                }
            }
        }
    }
}
