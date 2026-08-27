pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

FocusScope {
    id: root

    property bool selecting: false
    property string category: "All"
    readonly property var categories: ["All", "Calm", "Flow", "Audio"]
    readonly property var filteredScenes: root.filterScenes()

    focus: visible
    clip: true

    onVisibleChanged: {
        if (visible) RgbState.refresh()
        else root.selecting = false
    }

    function filterScenes() {
        var result = []
        for (var i = 0; i < RgbState.catalog.length; i++) {
            var item = RgbState.catalog[i]
            if (root.category === "All" || item.category === root.category) result.push(item)
        }
        return result
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            spacing: 7

            IconButton {
                visible: root.selecting
                icon: "󰅁"
                tooltip: "Back to scene controls"
                onClicked: root.selecting = false
            }

            Text {
                text: RgbState.sceneIcon(RgbState.scene)
                color: RgbState.accentColor
                font.family: Theme.fontFamily
                font.pixelSize: 22
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: 0
                Text {
                    text: root.selecting ? "Choose a scene" : RgbState.sceneName
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: root.selecting ? root.filteredScenes.length + " scenes" : RgbState.statusLabel
                    color: RgbState.errorMessage.length > 0 ? Theme.danger
                        : (RgbState.applying ? Theme.warning : (RgbState.available ? Theme.muted : Theme.danger))
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            IconButton {
                visible: !root.selecting
                icon: "󰕮"
                tooltip: "Choose RGB scene"
                selected: root.selecting
                onClicked: root.selecting = true
            }
            IconButton {
                visible: !root.selecting
                icon: "󰑐"
                tooltip: "Reset scene settings"
                enabled: RgbState.ready && !RgbState.applying
                opacity: enabled ? 1 : 0.4
                onClicked: RgbState.resetScene()
            }
            IconButton {
                visible: !root.selecting
                icon: RgbState.power ? "󰌵" : "󰌶"
                tooltip: RgbState.power ? "Turn RGB lighting off" : "Resume RGB lighting"
                selected: RgbState.power
                iconColor: RgbState.power ? RgbState.accentColor : Theme.subtle
                enabled: RgbState.ready && !RgbState.applying
                opacity: enabled ? 1 : 0.4
                onClicked: RgbState.togglePower()
            }
        }

        Text {
            visible: RgbState.errorMessage.length > 0
            text: RgbState.errorMessage
            color: Theme.danger
            font.family: Theme.fontFamily
            font.pixelSize: Theme.smallFontSize
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 14 : 0
        }

        Item {
            visible: root.selecting
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 7

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Repeater {
                        model: root.categories
                        delegate: Rectangle {
                            id: categoryButton
                            required property string modelData
                            readonly property bool selected: root.category === modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.controlHeight
                            activeFocusOnTab: true
                            Accessible.role: Accessible.RadioButton
                            Accessible.name: modelData + " RGB scenes"
                            Accessible.checked: selected
                            radius: Theme.smallRadius
                            color: selected ? Theme.tint(Theme.accentAlt, 0.16)
                                : (categoryMouse.containsMouse || activeFocus ? Theme.surface : Theme.backgroundElevated)
                            border.width: activeFocus ? 1 : 0
                            border.color: Theme.accentAlt
                            Text { anchors.centerIn: parent; text: categoryButton.modelData; color: categoryButton.selected ? Theme.accentAlt : Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.smallFontSize }
                            MouseArea { id: categoryMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onPressed: categoryButton.forceActiveFocus(Qt.MouseFocusReason); onClicked: root.category = categoryButton.modelData }
                            Accessible.onPressAction: root.category = categoryButton.modelData
                        }
                    }
                }

                Flickable {
                    id: sceneFlickable
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: width
                    contentHeight: sceneGrid.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    GridLayout {
                        id: sceneGrid
                        width: sceneFlickable.width - (sceneFlickable.contentHeight > sceneFlickable.height ? 7 : 0)
                        columns: 2
                        columnSpacing: 7
                        rowSpacing: 7

                        Repeater {
                            model: root.filteredScenes
                            delegate: Rectangle {
                                id: sceneCard
                                required property var modelData
                                readonly property bool selected: RgbState.scene === modelData.id
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                Layout.preferredHeight: 76
                                activeFocusOnTab: true
                                Accessible.role: Accessible.Button
                                Accessible.name: modelData.name + ", " + modelData.description
                                radius: Theme.smallRadius
                                color: selected ? Theme.tint(RgbState.accentColor, 0.14)
                                    : (sceneMouse.containsMouse || activeFocus ? Theme.surface : Theme.backgroundElevated)
                                border.width: selected || activeFocus ? 1 : 0
                                border.color: selected ? RgbState.accentColor : Theme.accentAlt

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 9
                                    spacing: 8
                                    Text { text: RgbState.sceneIcon(sceneCard.modelData.id); color: sceneCard.selected ? RgbState.accentColor : Theme.accentAlt; font.family: Theme.fontFamily; font.pixelSize: 20 }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        spacing: 2
                                        Text { text: sceneCard.modelData.name; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight; Layout.fillWidth: true }
                                        Text { text: sceneCard.modelData.description; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight; Layout.fillWidth: true }
                                    }
                                }

                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                                        event.accepted = true
                                        RgbState.setScene(sceneCard.modelData.id)
                                        root.selecting = false
                                    }
                                }
                                Accessible.onPressAction: {
                                    RgbState.setScene(sceneCard.modelData.id)
                                    root.selecting = false
                                }
                                MouseArea {
                                    id: sceneMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onPressed: sceneCard.forceActiveFocus(Qt.MouseFocusReason)
                                    onClicked: {
                                        RgbState.setScene(sceneCard.modelData.id)
                                        root.selecting = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Flickable {
            id: settingsFlickable
            visible: !root.selecting
            enabled: RgbState.ready && RgbState.available && !RgbState.applying
            opacity: enabled ? 1 : 0.55
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: settingsColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            ColumnLayout {
                id: settingsColumn
                width: settingsFlickable.width - (settingsFlickable.contentHeight > settingsFlickable.height ? 7 : 0)
                spacing: 7

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: Theme.smallRadius
                    color: Theme.backgroundElevated
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 6
                        Repeater {
                            model: RgbState.previewColors
                            delegate: Rectangle {
                                required property string modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 12
                                radius: 3
                                color: modelData
                            }
                        }
                    }
                }

                ColumnLayout {
                    visible: RgbState.currentSceneInfo.category === "Audio"
                    Layout.fillWidth: true
                    spacing: 3
                    CavaVisualizer {
                        active: visible && RgbState.power
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                    }
                    Text { text: "Audio reactive"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.smallFontSize; Layout.alignment: Qt.AlignHCenter }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 3
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Master brightness"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.smallFontSize; Layout.fillWidth: true }
                            Text { text: RgbState.brightness + "%"; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.bodyFontSize }
                        }
                        ValueSlider {
                            value: RgbState.brightness / 100
                            accent: RgbState.accentColor
                            accessibleName: "RGB master brightness"
                            Layout.fillWidth: true
                            onMoved: value => RgbState.setBrightness(value * 100)
                        }
                    }
                }

                Repeater {
                    model: RgbState.currentParams
                    delegate: Loader {
                        id: parameterLoader
                        required property var modelData
                        property var spec: modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: spec.type === "colors" ? 146
                            : (spec.type === "color" ? 118
                            : ((spec.type === "direction" || spec.type === "options") ? 58
                            : (spec.type === "toggle" ? 36 : 44)))
                        sourceComponent: spec.type === "slider" ? sliderControl
                            : (spec.type === "toggle" ? toggleControl
                            : (spec.type === "direction" ? directionControl
                            : (spec.type === "options" ? optionsControl : colorControl)))
                        onLoaded: if (item) item.spec = spec
                        onSpecChanged: if (item) item.spec = spec
                    }
                }

                Item { Layout.fillHeight: true; Layout.minimumHeight: 4 }
            }
        }
    }

    Component { id: sliderControl; RgbSliderControl { } }
    Component { id: toggleControl; RgbToggleControl { } }
    Component { id: directionControl; RgbDirectionControl { } }
    Component { id: optionsControl; RgbOptionsControl { } }
    Component { id: colorControl; RgbColorControl { } }
}
