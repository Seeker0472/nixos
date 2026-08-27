pragma ComponentBehavior: Bound

import QtQuick 6.0
import QtQuick.Layouts 6.0
import QtQuick.Controls 6.3

FocusScope {
    id: root

    property bool addPending: false
    readonly property var views: [
        { key: "all", label: "All", count: TaskState.totalCount },
        { key: "today", label: "Today", count: TaskState.overdueCount + TaskState.todayCount },
        { key: "upcoming", label: "Upcoming", count: TaskState.upcomingCount }
    ]

    focus: visible

    onVisibleChanged: {
        if (!visible) return
        TaskState.refresh()
        Qt.callLater(() => addField.forceActiveFocus(Qt.PopupFocusReason))
    }

    Component.onCompleted: {
        if (visible) Qt.callLater(() => addField.forceActiveFocus(Qt.PopupFocusReason))
    }

    function submitTask() {
        if (TaskState.addTask(addField.text)) root.addPending = true
    }

    Connections {
        target: TaskState
        function onMutationFinished(success) {
            if (!root.addPending) return
            if (success) addField.clear()
            root.addPending = false
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 9

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Repeater {
                model: root.views

                delegate: Rectangle {
                    id: viewButton
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    radius: Theme.smallRadius
                    color: TaskState.selectedView === modelData.key
                        ? Theme.tint(Theme.accent, 0.16)
                        : (viewMouse.containsMouse ? Theme.surface : Theme.backgroundElevated)

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: viewButton.modelData.label
                            color: Theme.text
                            font.family: "Maple Mono NF CN"
                            font.pixelSize: 11
                        }

                        Text {
                            text: viewButton.modelData.count
                            color: TaskState.selectedView === viewButton.modelData.key ? Theme.accent : Theme.muted
                            font.family: "Maple Mono NF CN"
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        id: viewMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: TaskState.selectedView = viewButton.modelData.key
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            TextField {
                id: addField
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredHeight: 36
                enabled: !TaskState.mutating
                focus: root.visible
                placeholderText: "Add a task"
                color: Theme.text
                placeholderTextColor: Theme.subtle
                selectionColor: Theme.accent
                selectedTextColor: Theme.background
                font.family: "Maple Mono NF CN"
                font.pixelSize: 12
                leftPadding: 11
                rightPadding: 11
                onAccepted: root.submitTask()

                TapHandler {
                    onTapped: addField.forceActiveFocus(Qt.MouseFocusReason)
                }

                background: Rectangle {
                    radius: Theme.smallRadius
                    color: Theme.backgroundElevated
                    border.width: addField.activeFocus ? 1 : 0
                    border.color: Theme.accent
                }
            }

            IconButton {
                icon: "󰐕"
                tooltip: "Add task"
                enabled: addField.text.trim().length > 0 && !TaskState.mutating
                opacity: enabled ? 1 : 0.4
                onClicked: root.submitTask()
            }

            IconButton {
                icon: "󰑐"
                tooltip: "Refresh tasks"
                enabled: !TaskState.loading
                opacity: enabled ? 1 : 0.4
                onClicked: TaskState.refresh()
            }
        }

        Text {
            visible: TaskState.errorMessage.length > 0 || TaskState.noticeMessage.length > 0
            text: TaskState.errorMessage.length > 0 ? TaskState.errorMessage : TaskState.noticeMessage
            color: TaskState.errorMessage.length > 0 ? Theme.danger : Theme.accentAlt
            font.family: "Maple Mono NF CN"
            font.pixelSize: 10
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 16 : 0
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: taskList
                anchors.fill: parent
                clip: true
                spacing: 6
                model: TaskState.visibleTasks
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    id: taskRow
                    required property var modelData
                    width: taskList.width
                    height: 62
                    radius: Theme.smallRadius
                    color: taskMouse.containsMouse
                        ? Theme.surface
                        : (TaskState.isOverdue(modelData) ? Theme.tint(Theme.danger, 0.08) : Theme.backgroundElevated)

                    MouseArea {
                        id: taskMouse
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        hoverEnabled: true
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 9

                        CheckBox {
                            id: doneBox
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                            enabled: !TaskState.mutating
                            hoverEnabled: true
                            checkable: false
                            checked: TaskState.completingUuid === taskRow.modelData.uuid
                            onClicked: TaskState.completeTask(taskRow.modelData.uuid)

                            indicator: Rectangle {
                                implicitWidth: 19
                                implicitHeight: 19
                                x: 1
                                y: 1
                                radius: 4
                                color: doneBox.checked ? Theme.accentAlt : "transparent"
                                border.width: 1
                                border.color: doneBox.hovered ? Theme.accentAlt : Theme.subtle

                                Text {
                                    visible: doneBox.checked
                                    anchors.centerIn: parent
                                    text: "✓"
                                    color: Theme.background
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                            }

                            contentItem: Item { }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 3

                            Text {
                                text: taskRow.modelData.description || "Untitled task"
                                color: Theme.text
                                font.family: "Maple Mono NF CN"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                            }

                            Text {
                                visible: text.length > 0
                                text: TaskState.taskContext(taskRow.modelData)
                                color: Theme.muted
                                font.family: "Maple Mono NF CN"
                                font.pixelSize: 9
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                            }
                        }

                        Text {
                            visible: text.length > 0
                            text: TaskState.dueLabel(taskRow.modelData)
                            color: TaskState.isOverdue(taskRow.modelData) ? Theme.danger
                                : (TaskState.isDueToday(taskRow.modelData) ? Theme.warning : Theme.muted)
                            font.family: "Maple Mono NF CN"
                            font.pixelSize: 10
                            Layout.maximumWidth: 96
                            elide: Text.ElideRight
                        }
                    }

                    HoverTooltip {
                        targetItem: doneBox
                        hovered: doneBox.hovered
                        text: "Complete task"
                        delay: 500
                    }
                }
            }

            Column {
                visible: !TaskState.loading && TaskState.visibleTasks.length === 0
                anchors.centerIn: parent
                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰄬"
                    color: Theme.accentAlt
                    font.family: "Maple Mono NF CN"
                    font.pixelSize: 30
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: TaskState.ready ? "No tasks in this view" : "Taskwarrior is not ready"
                    color: Theme.muted
                    font.family: "Maple Mono NF CN"
                    font.pixelSize: 11
                }
            }

            Text {
                visible: TaskState.loading && !TaskState.ready
                anchors.centerIn: parent
                text: "Loading tasks..."
                color: Theme.muted
                font.family: "Maple Mono NF CN"
                font.pixelSize: 11
            }
        }
    }
}
