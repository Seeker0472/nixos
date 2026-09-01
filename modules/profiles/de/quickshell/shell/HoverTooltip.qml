import QtQuick 6.0

Item {
    id: root

    property Item targetItem: null
    property string text: ""
    property bool hovered: false
    property bool focused: false
    property int delay: 500
    width: 0
    height: 0
    visible: false

    function sync() {
        TooltipState.update(root, root.targetItem, root.text, root.hovered, root.focused, root.delay)
    }

    function dismiss() {
        TooltipState.dismiss(root)
    }

    onTargetItemChanged: root.sync()
    onTextChanged: root.sync()
    onHoveredChanged: root.sync()
    onFocusedChanged: root.sync()
    onDelayChanged: root.sync()

    Component.onCompleted: root.sync()
    Component.onDestruction: TooltipState.release(root)
}
