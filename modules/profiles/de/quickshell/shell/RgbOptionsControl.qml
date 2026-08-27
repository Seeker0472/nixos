pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var spec: ({})
    readonly property string selectedValue: String(RgbState.currentSettings[spec.key] || "")

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
                model: root.spec.choices || []
                delegate: Rectangle {
                    id: choice
                    required property var modelData
                    readonly property bool selected: root.selectedValue === modelData.key
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

                    Text {
                        anchors.centerIn: parent
                        text: choice.modelData.label
                        color: choice.selected ? RgbState.accentColor : Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.smallFontSize
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
