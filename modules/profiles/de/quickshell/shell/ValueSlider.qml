import QtQuick 6.0

Item {
    id: root

    property real value: 0
    property real visualValue: value
    property color accent: Theme.accent
    signal moved(real value)

    implicitHeight: 22

    onValueChanged: {
        if (!mouseArea.pressed) {
            visualValue = value;
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: height / 2
        color: Theme.surface
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, Math.min(1, root.visualValue)) * parent.width
        height: 6
        radius: height / 2
        color: root.accent
    }

    Rectangle {
        x: Math.max(0, Math.min(1, root.visualValue)) * (parent.width - width)
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        radius: 8
        color: Theme.text
        border.width: 2
        border.color: root.accent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function updateValue(mouseX) {
            root.visualValue = Math.max(0, Math.min(1, mouseX / width))
            root.moved(root.visualValue)
        }
        onPressed: updateValue(mouse.x)
        onPositionChanged: if (pressed) updateValue(mouse.x)
    }
}
