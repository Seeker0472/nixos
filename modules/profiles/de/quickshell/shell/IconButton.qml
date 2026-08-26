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

    implicitWidth: content.implicitWidth + 20
    implicitHeight: 34
    radius: Theme.smallRadius
    color: selected ? Theme.surfaceStrong : (mouse.containsMouse ? Theme.surface : "transparent")
    border.width: selected ? 1 : 0
    border.color: Theme.accent

    Behavior on color {
        ColorAnimation { duration: 140 }
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 7

        Text {
            visible: root.icon.length > 0
            text: root.icon
            color: root.iconColor
            font.family: "Maple Mono NF CN"
            font.pixelSize: 16
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            visible: root.label.length > 0
            text: root.label
            color: Theme.text
            font.family: "Maple Mono NF CN"
            font.pixelSize: 12
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    HoverTooltip {
        targetItem: root
        hovered: mouse.containsMouse
        text: root.tooltip
        delay: 550
    }
}
