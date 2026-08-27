import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property var spec: ({})
    readonly property bool checked: Boolean(RgbState.currentSettings[spec.key])

    implicitHeight: 36
    activeFocusOnTab: true
    Accessible.role: Accessible.CheckBox
    Accessible.name: spec.label
    Accessible.checked: checked
    radius: Theme.smallRadius
    color: mouse.containsMouse || activeFocus ? Theme.surface : "transparent"
    border.width: activeFocus ? 1 : 0
    border.color: RgbState.accentColor

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            event.accepted = true
            RgbState.setSetting(root.spec.key, !root.checked)
        }
    }
    Accessible.onToggleAction: RgbState.setSetting(root.spec.key, !root.checked)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8

        Text {
            text: root.spec.label
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.bodyFontSize
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.preferredWidth: 34
            Layout.preferredHeight: 18
            radius: 9
            color: root.checked ? RgbState.accentColor : Theme.surfaceStrong
            Rectangle {
                x: root.checked ? parent.width - width - 3 : 3
                anchors.verticalCenter: parent.verticalCenter
                width: 12
                height: 12
                radius: 6
                color: root.checked ? Theme.background : Theme.muted
                Behavior on x { NumberAnimation { duration: Theme.animationFast } }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: root.forceActiveFocus(Qt.MouseFocusReason)
        onClicked: RgbState.setSetting(root.spec.key, !root.checked)
    }
}
