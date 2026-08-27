import QtQuick 6.0

Item {
    id: root

    property real value: 0
    property real visualValue: value
    property color accent: Theme.accent
    property string accessibleName: "Value"
    signal moved(real value)

    implicitHeight: 22
    activeFocusOnTab: enabled
    Accessible.role: Accessible.Slider
    Accessible.name: root.accessibleName

    Keys.onPressed: event => {
        var next = root.visualValue
        if (event.key === Qt.Key_Left || event.key === Qt.Key_Down) next -= 0.05
        else if (event.key === Qt.Key_Right || event.key === Qt.Key_Up) next += 0.05
        else if (event.key === Qt.Key_Home) next = 0
        else if (event.key === Qt.Key_End) next = 1
        else return
        event.accepted = true
        root.visualValue = Math.max(0, Math.min(1, next))
        root.moved(root.visualValue)
    }

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

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: "transparent"
        border.width: root.activeFocus ? 1 : 0
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
        onPressed: {
            root.forceActiveFocus(Qt.MouseFocusReason)
            updateValue(mouse.x)
        }
        onPositionChanged: if (pressed) updateValue(mouse.x)
    }
}
