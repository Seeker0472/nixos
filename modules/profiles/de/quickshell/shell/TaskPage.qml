pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

FocusScope {
    id: root

    property var editingTask: null
    property string priority: ""
    property bool deletePending: false
    readonly property bool editing: editingTask !== null
    readonly property var views: [
        { key: "inbox", label: "Inbox", count: TaskState.inboxCount },
        { key: "today", label: "Today", count: TaskState.overdueCount + TaskState.todayCount },
        { key: "upcoming", label: "Upcoming", count: TaskState.upcomingCount },
        { key: "all", label: "All", count: TaskState.totalCount }
    ]

    focus: visible

    onVisibleChanged: {
        if (!visible) return
        TaskState.pageOpened()
        Qt.callLater(() => descriptionField.forceActiveFocus(Qt.PopupFocusReason))
    }

    Connections {
        target: TaskState
        function onMutationFinished(operation, success) {
            if (!success) return
            if (operation === "add") root.clearForm()
            else if (operation === "edit" || operation === "delete") root.cancelEdit()
        }
    }

    function todayText(offset) {
        var date = new Date()
        date.setDate(date.getDate() + Number(offset || 0))
        return Qt.formatDate(date, "yyyy-MM-dd")
    }

    function formFields() {
        return {
            description: descriptionField.text,
            due: dueField.text,
            project: projectField.text,
            tags: tagsField.text,
            priority: root.priority
        }
    }

    function submitTask() {
        if (root.editing) TaskState.modifyTask(root.editingTask, root.formFields())
        else TaskState.addTask(root.formFields())
    }

    function clearForm() {
        descriptionField.clear()
        dueField.clear()
        projectField.clear()
        tagsField.clear()
        root.priority = ""
        root.deletePending = false
        Qt.callLater(() => descriptionField.forceActiveFocus(Qt.OtherFocusReason))
    }

    function editTask(task) {
        root.editingTask = task
        root.deletePending = false
        descriptionField.text = String(task.description || "")
        dueField.text = TaskState.dueInput(task)
        projectField.text = String(task.project || "")
        tagsField.text = Array.isArray(task.tags) ? task.tags.join(", ") : ""
        root.priority = String(task.priority || "")
        Qt.callLater(() => descriptionField.forceActiveFocus(Qt.OtherFocusReason))
    }

    function cancelEdit() {
        root.editingTask = null
        root.clearForm()
    }

    function requestDelete(task) {
        if (!root.editing || root.editingTask.uuid !== task.uuid) root.editTask(task)
        root.deletePending = true
    }

    Keys.onEscapePressed: event => {
        if (root.deletePending) {
            root.deletePending = false
            event.accepted = true
        } else if (root.editing) {
            root.cancelEdit()
            event.accepted = true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            spacing: 3

            Repeater {
                model: root.views
                delegate: Rectangle {
                    id: viewButton
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.preferredHeight: Theme.controlHeight
                    activeFocusOnTab: true
                    Accessible.role: Accessible.Button
                    Accessible.name: modelData.label + ", " + modelData.count + " tasks"
                    radius: Theme.smallRadius
                    color: TaskState.selectedView === modelData.key
                        ? Theme.tint(Theme.accent, 0.16)
                        : ((viewMouse.containsMouse || activeFocus) ? Theme.surface : Theme.backgroundElevated)
                    border.width: activeFocus ? 1 : 0
                    border.color: Theme.accent

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                            event.accepted = true
                            TaskState.selectedView = viewButton.modelData.key
                        }
                    }
                    Accessible.onPressAction: TaskState.selectedView = viewButton.modelData.key

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: viewButton.modelData.label; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.smallFontSize }
                        Text { text: viewButton.modelData.count; color: TaskState.selectedView === viewButton.modelData.key ? Theme.accent : Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                    }

                    MouseArea {
                        id: viewMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: viewButton.forceActiveFocus(Qt.MouseFocusReason)
                        onClicked: TaskState.selectedView = viewButton.modelData.key
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            ShellTextField {
                id: descriptionField
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                enabled: !TaskState.busy
                accessibleName: "Task description"
                placeholderText: root.editing ? "Edit task description" : "Add a task"
                onAccepted: root.submitTask()
            }

            IconButton {
                icon: root.editing ? "󰆓" : "󰐕"
                tooltip: root.editing ? "Save task" : "Add task"
                enabled: descriptionField.text.trim().length > 0 && !TaskState.busy
                opacity: enabled ? 1 : 0.4
                onClicked: root.submitTask()
            }

            IconButton {
                visible: root.editing
                icon: "󰜺"
                tooltip: "Cancel editing"
                onClicked: root.cancelEdit()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            ShellTextField {
                id: dueField
                Layout.preferredWidth: 112
                enabled: !TaskState.busy
                accessibleName: "Due date"
                placeholderText: "YYYY-MM-DD"
                inputMethodHints: Qt.ImhDate
            }
            IconButton { label: "Today"; tooltip: "Due today"; enabled: !TaskState.busy; onClicked: dueField.text = root.todayText(0) }
            IconButton { label: "+1"; tooltip: "Due tomorrow"; enabled: !TaskState.busy; onClicked: dueField.text = root.todayText(1) }
            IconButton { icon: "×"; tooltip: "Remove due date"; enabled: dueField.text.length > 0 && !TaskState.busy; onClicked: dueField.clear() }

            Item { Layout.fillWidth: true }

            Repeater {
                model: ["", "H", "M", "L"]
                delegate: IconButton {
                    required property string modelData
                    label: modelData.length > 0 ? modelData : "-"
                    tooltip: modelData.length > 0 ? "Priority " + modelData : "No priority"
                    selected: root.priority === modelData
                    enabled: !TaskState.busy
                    onClicked: root.priority = modelData
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            ShellTextField { id: projectField; Layout.fillWidth: true; Layout.minimumWidth: 80; enabled: !TaskState.busy; accessibleName: "Project"; placeholderText: "Project" }
            ShellTextField { id: tagsField; Layout.fillWidth: true; Layout.minimumWidth: 100; enabled: !TaskState.busy; accessibleName: "Tags"; placeholderText: "Tags, comma separated" }
            IconButton {
                visible: root.editing
                icon: "󰆴"
                tooltip: root.deletePending ? "Confirm delete task" : "Delete task"
                iconColor: Theme.danger
                selected: root.deletePending
                enabled: !TaskState.busy
                onClicked: {
                    if (root.deletePending) TaskState.deleteTask(root.editingTask.uuid)
                    else root.deletePending = true
                }
            }
        }

        Rectangle {
            visible: root.deletePending || TaskState.canUndo || TaskState.errorMessage.length > 0 || TaskState.noticeMessage.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 30 : 0
            radius: Theme.smallRadius
            color: root.deletePending || TaskState.errorMessage.length > 0
                ? Theme.tint(Theme.danger, 0.12) : Theme.backgroundElevated

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 9
                anchors.rightMargin: 4
                spacing: 5
                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: root.deletePending ? "Delete this task?"
                        : (TaskState.errorMessage.length > 0 ? TaskState.errorMessage
                        : (TaskState.canUndo ? TaskState.undoMessage : TaskState.noticeMessage))
                    color: root.deletePending || TaskState.errorMessage.length > 0 ? Theme.danger : Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.smallFontSize
                    elide: Text.ElideRight
                }
                IconButton { visible: root.deletePending; label: "Cancel"; tooltip: "Cancel deletion"; onClicked: root.deletePending = false }
                IconButton { visible: root.deletePending; label: "Delete"; tooltip: "Confirm deletion"; iconColor: Theme.danger; onClicked: TaskState.deleteTask(root.editingTask.uuid) }
                IconButton { visible: TaskState.canUndo && !root.deletePending; label: "Undo"; tooltip: "Undo completion"; onClicked: TaskState.undoLastCompletion() }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            Text {
                Layout.fillWidth: true
                text: TaskState.syncStatusLabel + (TaskState.syncMessage.length > 0 ? " · " + TaskState.syncMessage : "")
                color: TaskState.syncStatus === "error" ? Theme.danger : Theme.subtle
                font.family: Theme.fontFamily
                font.pixelSize: 9
                elide: Text.ElideRight
            }
            IconButton { icon: "󰑐"; tooltip: TaskState.syncConfigured ? "Sync tasks" : "Refresh tasks"; enabled: !TaskState.busy && !TaskState.loading; onClicked: TaskState.syncConfigured ? TaskState.requestSync() : TaskState.refresh() }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: taskList
                anchors.fill: parent
                clip: true
                spacing: 5
                model: TaskState.visibleTasks
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    id: taskRow
                    required property var modelData
                    width: taskList.width
                    height: 58
                    activeFocusOnTab: true
                    Accessible.role: Accessible.ListItem
                    Accessible.name: String(modelData.description || "Untitled task")
                    radius: Theme.smallRadius
                    color: rowMouse.containsMouse || activeFocus
                        ? Theme.surface
                        : (TaskState.isOverdue(modelData) ? Theme.tint(Theme.danger, 0.08) : Theme.backgroundElevated)
                    border.width: activeFocus ? 1 : 0
                    border.color: Theme.accent

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Space) {
                            event.accepted = true
                            TaskState.completeTask(taskRow.modelData.uuid)
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            event.accepted = true
                            root.editTask(taskRow.modelData)
                        } else if (event.key === Qt.Key_Delete) {
                            event.accepted = true
                            root.requestDelete(taskRow.modelData)
                        }
                    }

                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        anchors.leftMargin: 40
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: taskRow.forceActiveFocus(Qt.MouseFocusReason)
                        onClicked: root.editTask(taskRow.modelData)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 9
                        anchors.rightMargin: 9
                        spacing: 8

                        CheckBox {
                            id: doneBox
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                            enabled: !TaskState.busy
                            hoverEnabled: true
                            checkable: false
                            checked: TaskState.completingUuid === taskRow.modelData.uuid
                            Accessible.name: "Complete " + taskRow.modelData.description
                            onClicked: TaskState.completeTask(taskRow.modelData.uuid)
                            indicator: Rectangle {
                                implicitWidth: 19
                                implicitHeight: 19
                                x: 1
                                y: 1
                                radius: 4
                                color: doneBox.checked ? Theme.accentAlt : "transparent"
                                border.width: doneBox.activeFocus || doneBox.hovered ? 2 : 1
                                border.color: doneBox.activeFocus || doneBox.hovered ? Theme.accentAlt : Theme.subtle
                                Text { visible: doneBox.checked; anchors.centerIn: parent; text: "✓"; color: Theme.background; font.pixelSize: Theme.bodyFontSize; font.weight: Font.Bold }
                            }
                            contentItem: Item { }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 2
                            Text { text: taskRow.modelData.description || "Untitled task"; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.bodyFontSize; elide: Text.ElideRight; Layout.fillWidth: true; Layout.minimumWidth: 0 }
                            Text { visible: text.length > 0; text: TaskState.taskContext(taskRow.modelData); color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; elide: Text.ElideRight; Layout.fillWidth: true; Layout.minimumWidth: 0 }
                        }

                        Text {
                            visible: text.length > 0
                            text: TaskState.dueLabel(taskRow.modelData)
                            color: TaskState.isOverdue(taskRow.modelData) ? Theme.danger : (TaskState.isDueToday(taskRow.modelData) ? Theme.warning : Theme.muted)
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.smallFontSize
                            Layout.maximumWidth: 90
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            Column {
                visible: !TaskState.loading && TaskState.visibleTasks.length === 0
                anchors.centerIn: parent
                spacing: 5
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰄬"; color: Theme.accentAlt; font.family: Theme.fontFamily; font.pixelSize: 28 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: TaskState.ready ? "No tasks in this view" : "Taskwarrior is not ready"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 11 }
            }

            Text { visible: TaskState.loading && !TaskState.ready; anchors.centerIn: parent; text: "Loading tasks..."; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 11 }
        }
    }
}
