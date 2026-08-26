import QtQuick 6.0
import QtQuick.Layouts 6.0
import QtQuick.Controls 6.0

Item {
    id: root

    property var screen: null
    property var outputName: screen && screen.name ? screen.name : ""

    implicitWidth: workspaces.implicitWidth
    implicitHeight: 32
    clip: true

    RowLayout {
        id: workspaces
        anchors.fill: parent
        spacing: 4

        Repeater {
            model: ShellState.workspacesFor(root.outputName)

            delegate: Rectangle {
                required property var modelData
                readonly property bool focused: Boolean(modelData.is_focused)
                readonly property bool activeOnOutput: Boolean(modelData.is_active)
                readonly property bool urgent: Boolean(modelData.is_urgent)
                readonly property bool empty: modelData.active_window_id === null || modelData.active_window_id === undefined
                readonly property real baseOpacity: empty && !focused && !urgent ? 0.68 : 1
                property real pulseOpacity: 1

                implicitWidth: Math.min(132, Math.max(28, workspaceLabel.implicitWidth + 18))
                implicitHeight: 30
                radius: Theme.smallRadius
                color: urgent ? Theme.danger : (focused ? Theme.accent : (mouse.containsMouse ? Theme.surfaceStrong : Theme.backgroundElevated))
                border.width: urgent || (activeOnOutput && !focused) ? 1 : 0
                border.color: urgent ? Theme.danger : Theme.accentAlt
                opacity: urgent ? pulseOpacity : baseOpacity

                Behavior on color {
                    ColorAnimation { duration: 140 }
                }
                SequentialAnimation on pulseOpacity {
                    running: urgent
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.58; duration: 650 }
                    NumberAnimation { to: 1.0; duration: 650 }
                }

                Text {
                    id: workspaceLabel
                    anchors.centerIn: parent
                    width: parent.width - 12
                    text: ShellState.workspaceLabel(modelData)
                    color: urgent || focused ? Theme.background : (empty ? Theme.muted : Theme.text)
                    font.family: "Maple Mono NF CN"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ShellState.focusWorkspace(Number(modelData.idx || 1), modelData.output || root.outputName)
                }

                ToolTip {
                    visible: mouse.containsMouse
                    delay: 450
                    text: {
                        var state = focused ? "focused" : (activeOnOutput ? "active" : "inactive")
                        if (empty) state += ", empty"
                        if (urgent) state += ", urgent"
                        return "Workspace " + ShellState.workspaceLabel(modelData) + " · " + state +
                            (modelData.output ? "\n" + modelData.output : "")
                    }
                }
            }
        }
    }
}
