pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "FanLogic.js" as FanLogic

Item {
    id: root

    required property string group
    required property string title
    required property string icon
    property string rpmSummary: "-- RPM"
    readonly property var settings: group === "cpu" ? FanState.cpuSettings : FanState.caseSettings
    readonly property bool editable: FanState.softwareMode && FanState.available && !FanState.applying
    readonly property var sliderSpecs: root.makeSliderSpecs()

    implicitHeight: 176

    function makeSliderSpecs() {
        var cpu = root.group === "cpu"
        return [
            { key: "minPwm", label: "Minimum", min: 64, max: cpu ? 160 : 128, step: 8, unit: "%" },
            { key: "startTemp", label: "Ramp from", min: 40, max: 65, step: 1, unit: "°C" },
            { key: "fullTemp", label: "Full speed", min: cpu ? 70 : 65, max: 85, step: 1, unit: "°C" }
        ]
    }

    function displayValue(spec) {
        var value = Number(root.settings[spec.key] || 0)
        return spec.key === "minPwm" ? FanLogic.pwmPercent(value) + "%" : Math.round(value) + spec.unit
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 7

            Text {
                text: root.icon
                color: FanState.accentColor
                font.family: Theme.fontFamily
                font.pixelSize: 19
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: 0
                Text {
                    text: root.title
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.bodyFontSize
                    font.weight: Font.DemiBold
                }
                Text {
                    text: root.settings.zeroRpm
                        ? "Stopped below " + root.settings.startTemp + "°C"
                        : "Minimum " + FanLogic.pwmPercent(root.settings.minPwm) + "%"
                    color: root.settings.zeroRpm ? Theme.warning : Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                }
            }
            Text {
                text: root.rpmSummary
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.smallFontSize
            }
            IconButton {
                icon: root.settings.zeroRpm ? "󰌶" : "󰌵"
                tooltip: root.settings.zeroRpm ? "Resume minimum fan speed" : "Enable protected zero RPM"
                selected: !root.settings.zeroRpm
                iconColor: root.settings.zeroRpm ? Theme.warning : FanState.accentColor
                enabled: root.editable
                opacity: enabled ? 1 : 0.4
                onClicked: FanState.setZeroRpm(root.group, !root.settings.zeroRpm)
            }
        }

        Repeater {
            model: root.sliderSpecs
            delegate: Item {
                id: sliderRow
                required property var modelData
                readonly property real actualValue: Number(root.settings[sliderRow.modelData.key] || sliderRow.modelData.min)
                Layout.fillWidth: true
                Layout.preferredHeight: 43
                opacity: root.editable && !(root.settings.zeroRpm && modelData.key === "minPwm") ? 1 : 0.45

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 2
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: sliderRow.modelData.label
                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.smallFontSize
                            Layout.fillWidth: true
                        }
                        Text {
                            text: root.displayValue(sliderRow.modelData)
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.smallFontSize
                        }
                    }
                    ValueSlider {
                        value: FanLogic.normalized(
                            sliderRow.actualValue,
                            Number(sliderRow.modelData.min),
                            Number(sliderRow.modelData.max)
                        )
                        accent: FanState.accentColor
                        accessibleName: root.title + " " + sliderRow.modelData.label
                        enabled: root.editable && !(root.settings.zeroRpm && sliderRow.modelData.key === "minPwm")
                        Layout.fillWidth: true
                        onMoved: value => {
                            var minimum = Number(sliderRow.modelData.min)
                            var maximum = Number(sliderRow.modelData.max)
                            var step = Number(sliderRow.modelData.step)
                            var raw = minimum + value * (maximum - minimum)
                            var stepped = Math.round((raw - minimum) / step) * step + minimum
                            FanState.setSetting(root.group, sliderRow.modelData.key, stepped)
                        }
                    }
                }
            }
        }
    }
}
