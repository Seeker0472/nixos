import QtQuick 6.0
import QtQuick.Layouts 6.0
import QtQuick.Controls 6.0

Rectangle {
    id: root

    property string icon: ""
    property string value: ""
    property string tooltip: ""
    property color accent: Theme.accentAlt
    property bool selected: false
    signal clicked

    implicitWidth: content.implicitWidth + 20
    implicitHeight: 30
    radius: Theme.smallRadius
    color: selected ? Qt.darker(root.accent, 2.7) : (mouse.containsMouse ? Theme.surface : Theme.backgroundElevated)
    border.width: mouse.containsMouse || selected ? 1 : 0
    border.color: root.accent

    Behavior on color {
        ColorAnimation { duration: 140 }
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.icon
            color: root.accent
            font.family: "Maple Mono NF CN"
            font.pixelSize: 15
        }

        Text {
            visible: root.value.length > 0
            text: root.value
            color: Theme.text
            font.family: "Maple Mono NF CN"
            font.pixelSize: 11
            elide: Text.ElideRight
            Layout.maximumWidth: 150
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    ToolTip {
        visible: mouse.containsMouse && root.tooltip.length > 0
        text: root.tooltip
        delay: 550
    }
}
