import QtQuick 6.0
import Quickshell

PopupWindow {
    id: root

    anchor.window: TooltipState.targetWindow
    anchor.rect.x: TooltipState.anchorX
    anchor.rect.y: TooltipState.anchorY
    anchor.rect.width: TooltipState.anchorWidth
    anchor.rect.height: TooltipState.anchorHeight
    anchor.edges: Edges.Bottom | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.ResizeY
    anchor.margins.bottom: -8

    color: "transparent"
    mask: Region {}
    grabFocus: false
    visible: TooltipState.shown && TooltipState.text.length > 0 &&
        TooltipState.targetWindow !== null && !TooltipState.panelOpen
    implicitWidth: Math.min(360, Math.max(104, naturalText.implicitWidth + 20))
    implicitHeight: Math.max(30, tooltipText.implicitHeight + 18)

    onVisibleChanged: if (!root.visible && TooltipState.shown && !TooltipState.panelOpen)
        TooltipState.dismissCurrent()

    Rectangle {
        anchors.fill: parent
        radius: Theme.smallRadius
        color: Theme.surface
        border.width: 0

        Text {
            id: naturalText
            visible: false
            text: TooltipState.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.bodyFontSize
            wrapMode: Text.NoWrap
        }

        Text {
            id: tooltipText
            x: 10
            y: 9
            width: Math.max(0, root.width - 20)
            text: TooltipState.text
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
