import QtQuick 6.0
import QtQuick.Layouts 6.0

Rectangle {
    id: root

    property string icon: ""
    property string value: ""
    property string tooltip: ""
    property color accent: Theme.accentAlt
    property bool selected: false
    property bool blinking: false
    property real pulseOpacity: 1
    signal clicked
    signal rightClicked
    signal middleClicked
    signal scrolled(int direction)

    implicitWidth: content.implicitWidth + 20
    implicitHeight: 30
    opacity: root.blinking ? root.pulseOpacity : 1
    radius: Theme.smallRadius
    color: selected ? Theme.surface : (mouse.containsMouse ? Theme.surface : "transparent")
    border.width: mouse.containsMouse || selected ? 1 : 0
    border.color: selected ? root.accent : Theme.surfaceStrong

    Behavior on color {
        ColorAnimation { duration: 140 }
    }

    SequentialAnimation on pulseOpacity {
        running: root.blinking
        loops: Animation.Infinite
        NumberAnimation { to: 0.52; duration: 650; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1; duration: 650; easing.type: Easing.InOutSine }
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
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: event => {
            if (event.button === Qt.LeftButton) root.clicked()
            else if (event.button === Qt.RightButton) root.rightClicked()
            else if (event.button === Qt.MiddleButton) root.middleClicked()
        }
        onWheel: event => {
            var delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x
            if (delta !== 0) root.scrolled(delta > 0 ? 1 : -1)
            event.accepted = true
        }
    }

    HoverTooltip {
        targetItem: root
        hovered: mouse.containsMouse
        text: root.tooltip
        delay: 550
    }
}
