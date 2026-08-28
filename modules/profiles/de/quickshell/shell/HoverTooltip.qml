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
    readonly property bool panelOpen: UiState.popupOpen

    anchor.item: root.targetItem
    anchor.edges: Edges.Bottom | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    // Keep the tooltip below its target. Only horizontal overflow may slide.
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.ResizeY
    // Margins are removed from the anchor rect, so a negative bottom margin creates the gap.
    anchor.margins.bottom: -8

    color: "transparent"
    // A tooltip is informational; it must not take the pointer away from its target.
    mask: Region {}
    grabFocus: false
    visible: root.shown && root.text.length > 0 && root.targetItem !== null && !root.panelOpen
    implicitWidth: Math.min(root.maxTextWidth + 20, Math.max(104, naturalText.implicitWidth + 20))
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

    onPanelOpenChanged: {
        showTimer.stop()
        root.shown = false
        if (!root.panelOpen && root.hovered && root.text.length > 0) showTimer.restart()
    }

    onVisibleChanged: {
        if (root.visible) root.anchor.updateAnchor()
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: Theme.surface
        border.width: 0

        Text {
            id: naturalText
            visible: false
            text: root.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.bodyFontSize
            wrapMode: Text.NoWrap
        }

        Text {
            id: tooltipText
            x: 10
            y: 9
            width: Math.max(0, root.width - 20)
            text: root.text
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.bodyFontSize
            lineHeight: 1.05
            wrapMode: Text.Wrap
            maximumLineCount: 6
            elide: Text.ElideRight
        }
    }
}
