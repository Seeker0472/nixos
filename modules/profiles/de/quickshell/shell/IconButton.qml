import QtQuick 6.0
import QtQuick.Layouts 6.0

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property string tooltip: ""
    property color iconColor: Theme.text
    property bool selected: false
    signal clicked

    implicitWidth: content.implicitWidth + 14
    implicitHeight: Theme.controlHeight
    activeFocusOnTab: enabled
    Accessible.role: Accessible.Button
    Accessible.name: tooltip.length > 0 ? tooltip : (label.length > 0 ? label : icon)
    radius: Theme.smallRadius
    color: selected ? Theme.tint(Theme.accent, 0.16) : ((mouse.containsMouse || activeFocus) ? Theme.surface : "transparent")
    border.width: activeFocus ? 1 : 0
    border.color: Theme.accent

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            event.accepted = true
            root.clicked()
        }
    }
    Accessible.onPressAction: if (root.enabled) root.clicked()

    Behavior on color {
        ColorAnimation { duration: Theme.animationFast }
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 6

        Text {
            visible: root.icon.length > 0
            text: root.icon
            color: root.iconColor
            font.family: Theme.fontFamily
            font.pixelSize: 17
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            visible: root.label.length > 0
            text: root.label
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.bodyFontSize
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onPressed: root.forceActiveFocus(Qt.MouseFocusReason)
        onClicked: if (root.enabled) root.clicked()
    }

    HoverTooltip {
        targetItem: root
        hovered: mouse.containsMouse || root.activeFocus
        text: root.tooltip
        delay: 550
    }
}
