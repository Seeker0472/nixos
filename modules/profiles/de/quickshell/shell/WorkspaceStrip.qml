import QtQuick 6.0
import QtQuick.Layouts 6.0

Item {
    id: root

    property var screen: null
    property var outputName: screen && screen.name ? screen.name : ""

    implicitWidth: workspaces.implicitWidth
    implicitHeight: 32

    RowLayout {
        id: workspaces
        anchors.fill: parent
        spacing: 4

        Repeater {
            model: ShellState.workspacesFor(root.outputName)

            delegate: Rectangle {
                required property var modelData
                readonly property bool active: Boolean(modelData.is_focused)
                readonly property bool visibleOnOutput: Boolean(modelData.is_active)

                implicitWidth: workspaceLabel.implicitWidth + 20
                implicitHeight: 30
                radius: height / 2
                color: active ? Theme.accent : (mouse.containsMouse ? Theme.surfaceStrong : Theme.backgroundElevated)
                border.width: visibleOnOutput && !active ? 1 : 0
                border.color: Theme.accentAlt

                Behavior on color {
                    ColorAnimation { duration: 140 }
                }

                Text {
                    id: workspaceLabel
                    anchors.centerIn: parent
                    text: ShellState.workspaceLabel(modelData)
                    color: active ? Theme.background : Theme.text
                    font.family: "Maple Mono NF CN"
                    font.pixelSize: 12
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ShellState.focusWorkspace(Number(modelData.idx || 1), modelData.output || "")
                }
            }
        }

    }
}
