import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var spec: ({})
    readonly property string direction: String(RgbState.currentSettings[spec.key] || "forward")
    readonly property var choices: [
        { key: "forward", label: "Forward", icon: "󰁔" },
        { key: "reverse", label: "Reverse", icon: "󰁍" }
    ]

    implicitHeight: 58

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        Text {
            text: root.spec.label
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.smallFontSize
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Repeater {
                model: root.choices
                delegate: Rectangle {
                    id: choice
                    required property var modelData
                    readonly property bool selected: root.direction === modelData.key
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.controlHeight
                    activeFocusOnTab: true
                    Accessible.role: Accessible.RadioButton
                    Accessible.name: modelData.label
                    Accessible.checked: selected
                    radius: Theme.smallRadius
                    color: selected ? Theme.tint(RgbState.accentColor, 0.18)
                        : (choiceMouse.containsMouse || activeFocus ? Theme.surface : Theme.backgroundElevated)
                    border.width: activeFocus ? 1 : 0
                    border.color: RgbState.accentColor

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5
                        Text { text: choice.modelData.icon; color: choice.selected ? RgbState.accentColor : Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 14 }
                        Text { text: choice.modelData.label; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.smallFontSize }
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                            event.accepted = true
                            RgbState.setSetting(root.spec.key, choice.modelData.key)
                        }
                    }
                    Accessible.onPressAction: RgbState.setSetting(root.spec.key, choice.modelData.key)
                    MouseArea {
                        id: choiceMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: choice.forceActiveFocus(Qt.MouseFocusReason)
                        onClicked: RgbState.setSetting(root.spec.key, choice.modelData.key)
                    }
                }
            }
        }
    }
}
