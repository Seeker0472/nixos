import QtQuick
import QtQuick.Controls

TextField {
    id: root

    property string accessibleName: placeholderText

    implicitHeight: Theme.fieldHeight
    color: Theme.text
    placeholderTextColor: Theme.subtle
    selectionColor: Theme.accent
    selectedTextColor: Theme.background
    font.family: Theme.fontFamily
    font.pixelSize: Theme.bodyFontSize
    leftPadding: 10
    rightPadding: 10
    Accessible.name: root.accessibleName

    background: Rectangle {
        radius: Theme.smallRadius
        color: Theme.backgroundElevated
        border.width: root.activeFocus ? 1 : 0
        border.color: Theme.accent
    }
}
