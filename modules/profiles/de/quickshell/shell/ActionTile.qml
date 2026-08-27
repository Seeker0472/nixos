import QtQuick 6.0
import QtQuick.Layouts 6.0

Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property color accent: Theme.accent
    signal clicked

    implicitHeight: 58
    radius: Theme.smallRadius
    // Blend the hover tint onto the tile first so the color animation stays opaque.
    readonly property color hoverColor: Qt.tint(
        Theme.backgroundElevated,
        Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.11)
    )
    color: mouse.containsMouse ? root.hoverColor : Theme.backgroundElevated
    border.width: 0

    Behavior on color {
        ColorAnimation { duration: 140 }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Text {
            text: root.icon
            color: root.accent
            font.family: "Maple Mono NF CN"
            font.pixelSize: 20
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            spacing: 1
            Layout.fillWidth: true
            Layout.minimumWidth: 0

            Text {
                text: root.title
                color: Theme.text
                font.family: "Maple Mono NF CN"
                font.pixelSize: 13
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                clip: true
            }

            Text {
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: Theme.muted
                font.family: "Maple Mono NF CN"
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                clip: true
            }
        }

        Text {
            text: "›"
            color: Theme.subtle
            font.pixelSize: 20
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
}
