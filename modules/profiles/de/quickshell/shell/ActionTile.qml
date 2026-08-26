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
    color: mouse.containsMouse ? Theme.surfaceStrong : Theme.backgroundElevated
    border.width: mouse.containsMouse ? 1 : 0
    border.color: root.accent

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

            Text {
                text: root.title
                color: Theme.text
                font.family: "Maple Mono NF CN"
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: Theme.muted
                font.family: "Maple Mono NF CN"
                font.pixelSize: 10
                elide: Text.ElideRight
                Layout.fillWidth: true
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
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
