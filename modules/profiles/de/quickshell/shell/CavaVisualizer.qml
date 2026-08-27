pragma ComponentBehavior: Bound

import QtQuick 6.0
import QtQuick.Layouts 6.0

Item {
    id: root

    property bool active: true
    readonly property bool paused: CavaState.paused

    implicitWidth: 92
    implicitHeight: 22

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.rightMargin: 2
        spacing: 2

        Repeater {
            model: CavaState.barCount

            delegate: Rectangle {
                required property int index
                readonly property real level: Math.max(CavaState.minimumLevel, Number(CavaState.levels[index] || CavaState.minimumLevel))
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignBottom
                Layout.minimumHeight: 3
                Layout.preferredHeight: Math.max(3, root.height * level)
                implicitHeight: 3
                radius: width / 2
                color: Theme.accentAlt
                opacity: 0.45 + level * 0.55
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        hoverEnabled: true
        onClicked: event => {
            if (event.button === Qt.RightButton && root.active) CavaState.paused = !CavaState.paused
        }
    }

    HoverTooltip {
        targetItem: root
        hovered: mouse.containsMouse
        text: root.paused ? "Audio visualizer paused" : (root.active && CavaState.active ? "Audio visualizer" : "Audio visualizer inactive")
        delay: 550
    }
}
