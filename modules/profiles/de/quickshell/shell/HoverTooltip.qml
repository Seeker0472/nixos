import QtQuick 6.0
import Quickshell

Item {
    id: root

    property Item targetItem: null
    property string text: ""
    property bool hovered: false
    property bool focused: false
    property int delay: 500
    readonly property var shellWindow: QsWindow.window
    width: 0
    height: 0
    visible: false

    function sync() {
        var rect = root.shellWindow && root.targetItem ?
            QsWindow.itemRect(root.targetItem) : null
        TooltipState.update(
            root, root.targetItem, root.shellWindow, rect,
            root.text, root.hovered, root.focused, root.delay
        )
    }

    function dismiss() {
        TooltipState.dismiss(root)
    }

    onTargetItemChanged: root.sync()
    onTextChanged: root.sync()
    onHoveredChanged: root.sync()
    onFocusedChanged: root.sync()
    onDelayChanged: root.sync()
    onShellWindowChanged: root.sync()

    Component.onCompleted: root.sync()
    Component.onDestruction: TooltipState.release(root)
}
