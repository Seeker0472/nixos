pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var spec: ({})
    property int selectedIndex: 0
    readonly property bool multiple: spec.type === "colors"
    readonly property var colors: multiple
        ? (Array.isArray(RgbState.currentSettings[spec.key]) ? RgbState.currentSettings[spec.key] : ["#FFFFFF"])
        : [String(RgbState.currentSettings[spec.key] || "#FFFFFF")]
    readonly property color currentColor: colors[Math.min(selectedIndex, colors.length - 1)] || "#FFFFFF"
    readonly property real hue: currentColor.hsvHue < 0 ? 0 : currentColor.hsvHue
    readonly property real saturation: currentColor.hsvSaturation
    readonly property real lightness: currentColor.hsvValue
    readonly property var swatches: [
        "#FFFFFF", "#F5C2E7", "#89DCEB", "#A6E3A1",
        "#F9E2AF", "#FF6A24", "#C7DCFF", "#966BFF"
    ]

    implicitHeight: multiple ? 146 : 118

    onColorsChanged: if (selectedIndex >= colors.length) selectedIndex = Math.max(0, colors.length - 1)

    function hex(colorValue) {
        function channel(value) {
            var result = Math.round(Math.max(0, Math.min(1, value)) * 255).toString(16).toUpperCase()
            return result.length < 2 ? "0" + result : result
        }
        return "#" + channel(colorValue.r) + channel(colorValue.g) + channel(colorValue.b)
    }

    function commit(colorValue) {
        var value = root.hex(colorValue)
        if (root.multiple) RgbState.setColorAt(root.spec.key, root.selectedIndex, value)
        else RgbState.setSetting(root.spec.key, value)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: root.spec.label
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.smallFontSize
                Layout.fillWidth: true
            }

            RowLayout {
                visible: root.multiple
                spacing: 3
                IconButton {
                    icon: "−"
                    tooltip: "Remove color"
                    enabled: root.colors.length > Number(root.spec.minItems || 1)
                    opacity: enabled ? 1 : 0.35
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    onClicked: RgbState.setColorCount(root.spec.key, root.colors.length - 1)
                }
                Text { text: root.colors.length; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.smallFontSize; Layout.preferredWidth: 12; horizontalAlignment: Text.AlignHCenter }
                IconButton {
                    icon: "+"
                    tooltip: "Add color"
                    enabled: root.colors.length < Number(root.spec.maxItems || 4)
                    opacity: enabled ? 1 : 0.35
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    onClicked: RgbState.setColorCount(root.spec.key, root.colors.length + 1)
                }
            }
        }

        RowLayout {
            visible: root.multiple
            Layout.fillWidth: true
            spacing: 6
            Repeater {
                model: root.colors
                delegate: Rectangle {
                    id: colorSlot
                    required property string modelData
                    required property int index
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: 4
                    color: modelData
                    border.width: root.selectedIndex === index ? 2 : 1
                    border.color: root.selectedIndex === index ? Theme.text : Theme.surfaceStrong
                    Accessible.role: Accessible.Button
                    Accessible.name: "Color " + (index + 1)
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedIndex = colorSlot.index }
                }
            }
            Item { Layout.fillWidth: true }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 4
                color: root.currentColor
                border.width: 1
                border.color: Theme.surfaceStrong
            }
            Repeater {
                model: root.swatches
                delegate: Rectangle {
                    id: swatch
                    required property string modelData
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    radius: 11
                    color: modelData
                    border.width: root.hex(root.currentColor) === modelData ? 2 : 1
                    border.color: root.hex(root.currentColor) === modelData ? Theme.text : Theme.surfaceStrong
                    Accessible.role: Accessible.Button
                    Accessible.name: "Set color " + modelData
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.commit(swatch.color) }
                }
            }
            Item { Layout.fillWidth: true }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 7
            Text { text: "Hue"; color: Theme.subtle; font.family: Theme.fontFamily; font.pixelSize: 9; Layout.preferredWidth: 42 }
            ValueSlider {
                value: root.hue
                accent: Qt.hsva(root.hue, 0.9, 1, 1)
                accessibleName: root.spec.label + " hue"
                Layout.fillWidth: true
                onMoved: value => root.commit(Qt.hsva(value, root.saturation, root.lightness, 1))
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 7
            Text { text: "Saturation"; color: Theme.subtle; font.family: Theme.fontFamily; font.pixelSize: 9; Layout.preferredWidth: 42 }
            ValueSlider {
                value: root.saturation
                accent: root.currentColor
                accessibleName: root.spec.label + " saturation"
                Layout.fillWidth: true
                onMoved: value => root.commit(Qt.hsva(root.hue, value, root.lightness, 1))
            }
        }
    }
}
