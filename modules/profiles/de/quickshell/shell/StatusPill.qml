import QtQuick 6.0
import QtQuick.Layouts 6.0

Rectangle {
    id: root

    property string icon: ""
    property string value: ""
    property string tooltip: ""
    property color accent: Theme.accentAlt
    property bool selected: false
    property bool highlighted: false
    property bool blinking: false
    property real pulseOpacity: 1
    signal clicked
    signal rightClicked
    signal middleClicked
    signal scrolled(int direction)

    implicitWidth: content.implicitWidth + 14
    implicitHeight: 28
    activeFocusOnTab: enabled
    Accessible.role: Accessible.Button
    Accessible.name: root.tooltip.length > 0 ? root.tooltip : root.value
    opacity: root.blinking ? root.pulseOpacity : 1
    radius: Theme.smallRadius
    color: (selected || highlighted) ? Theme.tint(root.accent, selected ? 0.16 : 0.11) : ((mouse.containsMouse || activeFocus) ? Theme.surface : "transparent")
    border.width: activeFocus ? 1 : 0
    border.color: root.accent

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            event.accepted = true
            tooltipAgent.dismiss()
            root.clicked()
        }
    }
    Accessible.onPressAction: {
        if (root.enabled) {
            tooltipAgent.dismiss()
            root.clicked()
        }
    }

    Behavior on color {
        ColorAnimation { duration: Theme.animationFast }
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
        spacing: 5

        Text {
            text: root.icon
            color: root.accent
            font.family: Theme.fontFamily
            font.pixelSize: 16
        }

        Text {
            visible: root.value.length > 0
            text: root.value
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.bodyFontSize
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
        onPressed: {
            tooltipAgent.dismiss()
            root.forceActiveFocus(Qt.MouseFocusReason)
        }
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
        id: tooltipAgent
        targetItem: root
        hovered: mouse.containsMouse
        focused: root.activeFocus
        text: root.tooltip
        delay: 550
    }
}
