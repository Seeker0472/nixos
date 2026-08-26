import QtQuick 6.0

Item {
    id: root

    property real value: 0
    property color fillColor: Theme.accent
    property color trackColor: Theme.surface

    implicitHeight: 6

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.trackColor
    }

    Rectangle {
        width: Math.max(0, Math.min(1, root.value)) * parent.width
        height: parent.height
        radius: height / 2
        color: root.fillColor
    }
}
