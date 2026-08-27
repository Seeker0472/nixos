import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var spec: ({})
    readonly property real actualValue: Number(RgbState.currentSettings[spec.key] === undefined
        ? spec.min : RgbState.currentSettings[spec.key])
    readonly property real normalizedValue: (actualValue - Number(spec.min)) /
        Math.max(1, Number(spec.max) - Number(spec.min))

    implicitHeight: 44

    function displayValue() {
        var unit = String(root.spec.unit || "")
        if (unit === "deg") return Math.round(root.actualValue) + "°"
        return Math.round(root.actualValue) + unit
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 3

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: root.spec.label
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.smallFontSize
                Layout.fillWidth: true
            }
            Text {
                text: root.displayValue()
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.bodyFontSize
            }
        }

        ValueSlider {
            value: root.normalizedValue
            accent: RgbState.accentColor
            accessibleName: root.spec.label
            Layout.fillWidth: true
            onMoved: value => {
                var minimum = Number(root.spec.min)
                var maximum = Number(root.spec.max)
                var step = Number(root.spec.step || 1)
                var raw = minimum + value * (maximum - minimum)
                var stepped = Math.round((raw - minimum) / step) * step + minimum
                RgbState.setSetting(root.spec.key, Math.max(minimum, Math.min(maximum, stepped)))
            }
        }
    }
}
