import QtQuick 6.0
import Quickshell

PopupWindow {
    id: root

    property Item targetItem: null
    property string text: ""
    property bool hovered: false
    property int delay: 500
    property int maxTextWidth: 340
    property bool shown: false

    anchor.item: root.targetItem
    anchor.edges: Edges.Bottom | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    // Keep the tooltip below its target. Only horizontal overflow may slide.
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.ResizeY
    // Margins are removed from the anchor rect, so a negative bottom margin creates the gap.
    anchor.margins.bottom: -8

    color: "transparent"
    grabFocus: false
    visible: root.shown && root.text.length > 0 && root.targetItem !== null
    implicitWidth: Math.min(root.maxTextWidth + 20, Math.max(96, tooltipText.implicitWidth + 20))
    implicitHeight: Math.max(30, tooltipText.implicitHeight + 18)

    Timer {
        id: showTimer
        interval: root.delay
        repeat: false
        onTriggered: root.shown = true
    }

    onHoveredChanged: {
        if (root.hovered && root.text.length > 0) {
            showTimer.restart()
        } else {
            showTimer.stop()
            root.shown = false
        }
    }

    onTextChanged: {
        if (root.text.length === 0) {
            showTimer.stop()
            root.shown = false
        } else if (root.hovered && !root.shown) {
            showTimer.restart()
        }
    }

    onVisibleChanged: {
        if (root.visible) root.anchor.updateAnchor()
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: Theme.backgroundElevated
        border.width: 1
        border.color: Theme.surfaceStrong

        Text {
            id: tooltipText
            anchors.fill: parent
            anchors.margins: 9
            text: root.text
            color: Theme.text
            font.family: "Maple Mono NF CN"
            font.pixelSize: 11
            lineHeight: 1.05
            wrapMode: Text.Wrap
            maximumLineCount: 6
            elide: Text.ElideRight
        }
    }
}
