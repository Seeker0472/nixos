pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var tasks: []
    property string selectedView: "all"
    property bool ready: false
    property bool loading: false
    property bool mutating: false
    property bool refreshQueued: false
    property string errorMessage: ""
    property string noticeMessage: ""
    property string pendingSuccessMessage: ""
    property string completingUuid: ""
    property date currentTime: new Date()

    signal mutationFinished(bool success)

    readonly property var visibleTasks: filteredTasks(root.tasks, root.selectedView, root.currentTime)
    readonly property int totalCount: root.tasks.length
    readonly property int overdueCount: countTasks(root.tasks, "overdue", root.currentTime)
    readonly property int todayCount: countTasks(root.tasks, "today", root.currentTime)
    readonly property int upcomingCount: countTasks(root.tasks, "upcoming", root.currentTime)
    readonly property string headerSummary: root.errorMessage.length > 0
        ? root.errorMessage
        : root.totalCount + " pending" + (root.overdueCount > 0 ? " · " + root.overdueCount + " overdue" : "")

    Process {
        id: queryProcess
        command: [Commands.task, "rc.json.array=on", "rc.color=off", "status:pending", "export"]
        stdout: StdioCollector { id: queryOutput }
        stderr: StdioCollector { id: queryError }
        onExited: (exitCode, exitStatus) => root.finishRefresh(exitCode, queryOutput.text, queryError.text)
    }

    Process {
        id: mutationProcess
        stdout: StdioCollector { id: mutationOutput }
        stderr: StdioCollector { id: mutationError }
        onExited: (exitCode, exitStatus) => root.finishMutation(exitCode, mutationOutput.text, mutationError.text)
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            root.currentTime = new Date()
            root.refresh()
        }
    }

    Timer {
        id: noticeTimer
        interval: 3500
        repeat: false
        onTriggered: root.noticeMessage = ""
    }

    Component.onCompleted: refresh()

    function refresh() {
        root.currentTime = new Date()
        if (queryProcess.running) {
            root.refreshQueued = true
            return
        }

        root.loading = true
        root.refreshQueued = false
        queryProcess.running = true
    }

    function addTask(description) {
        var text = String(description || "").trim()
        if (text.length === 0 || root.mutating) return false

        return runMutation(
            [Commands.task, "rc.confirmation=off", "rc.verbose=nothing", "add", "--", text],
            "Task added"
        )
    }

    function completeTask(uuid) {
        var taskUuid = String(uuid || "")
        if (taskUuid.length === 0 || root.mutating) return false

        var started = runMutation(
            [Commands.task, "rc.confirmation=off", "rc.verbose=nothing", taskUuid, "done"],
            "Task completed"
        )
        if (started) root.completingUuid = taskUuid
        return started
    }

    function runMutation(command, successMessage) {
        if (mutationProcess.running) return false

        root.mutating = true
        root.errorMessage = ""
        root.noticeMessage = ""
        root.pendingSuccessMessage = successMessage
        mutationProcess.command = command
        mutationProcess.running = true
        return true
    }

    function finishRefresh(exitCode, output, errorOutput) {
        root.loading = false

        if (exitCode !== 0) {
            root.errorMessage = cleanError(errorOutput, "Unable to load tasks")
        } else {
            try {
                var text = String(output || "").trim()
                var parsed = JSON.parse(text.length > 0 ? text : "[]")
                if (!Array.isArray(parsed)) throw new Error("Taskwarrior returned a non-array response")
                root.tasks = sortTasks(parsed)
                root.completingUuid = ""
                root.errorMessage = ""
                root.ready = true
            } catch (error) {
                root.errorMessage = "Invalid Taskwarrior response"
                console.warn("Failed to parse Taskwarrior export: " + error)
            }
        }

        if (root.refreshQueued) {
            root.refreshQueued = false
            root.refresh()
        }
    }

    function finishMutation(exitCode, output, errorOutput) {
        root.mutating = false

        if (exitCode !== 0) {
            root.errorMessage = cleanError(errorOutput || output, "Taskwarrior command failed")
            root.pendingSuccessMessage = ""
            root.completingUuid = ""
            root.mutationFinished(false)
            return
        }

        root.errorMessage = ""
        root.noticeMessage = root.pendingSuccessMessage
        root.pendingSuccessMessage = ""
        noticeTimer.restart()
        root.mutationFinished(true)
        root.refresh()
    }

    function cleanError(value, fallback) {
        var lines = String(value || "").split("\n")
        var useful = []
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line.length === 0 || line.indexOf("Configuration override ") === 0) continue
            useful.push(line)
        }
        return useful.length > 0 ? useful[0] : fallback
    }

    function parseDate(value) {
        var text = String(value || "")
        var match = /^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z$/.exec(text)
        if (match) {
            return new Date(Date.UTC(
                Number(match[1]), Number(match[2]) - 1, Number(match[3]),
                Number(match[4]), Number(match[5]), Number(match[6])
            ))
        }

        var timestamp = Date.parse(text)
        return isNaN(timestamp) ? null : new Date(timestamp)
    }

    function startOfDay(now) {
        return new Date(now.getFullYear(), now.getMonth(), now.getDate())
    }

    function startOfTomorrow(now) {
        return new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1)
    }

    function taskDue(task) {
        return task && task.due ? parseDate(task.due) : null
    }

    function isOverdue(task) {
        var due = taskDue(task)
        return due !== null && due < startOfDay(root.currentTime)
    }

    function isDueToday(task) {
        var due = taskDue(task)
        return due !== null && due >= startOfDay(root.currentTime) && due < startOfTomorrow(root.currentTime)
    }

    function dueLabel(task) {
        var due = taskDue(task)
        if (due === null) return ""
        if (due < startOfDay(root.currentTime)) return "Overdue · " + Qt.formatDate(due, "MMM d")
        if (due < startOfTomorrow(root.currentTime)) return "Today"

        var afterTomorrow = new Date(
            root.currentTime.getFullYear(), root.currentTime.getMonth(), root.currentTime.getDate() + 2
        )
        if (due < afterTomorrow) return "Tomorrow"
        return Qt.formatDate(due, "MMM d")
    }

    function taskContext(task) {
        var parts = []
        if (task && task.project) parts.push(String(task.project))
        if (task && Array.isArray(task.tags)) {
            for (var i = 0; i < task.tags.length; i++) parts.push("+" + task.tags[i])
        }
        return parts.join(" · ")
    }

    function countTasks(values, kind, now) {
        var start = startOfDay(now)
        var tomorrow = startOfTomorrow(now)
        var count = 0
        for (var i = 0; i < values.length; i++) {
            var due = taskDue(values[i])
            if (kind === "overdue" && due !== null && due < start) count++
            else if (kind === "today" && due !== null && due >= start && due < tomorrow) count++
            else if (kind === "upcoming" && due !== null && due >= tomorrow) count++
        }
        return count
    }

    function filteredTasks(values, view, now) {
        if (view === "all") return values

        var tomorrow = startOfTomorrow(now)
        return values.filter(task => {
            var due = taskDue(task)
            if (view === "today") return due !== null && due < tomorrow
            if (view === "upcoming") return due !== null && due >= tomorrow
            return true
        })
    }

    function sortTasks(values) {
        var sorted = values.slice()
        sorted.sort((left, right) => {
            var leftDue = taskDue(left)
            var rightDue = taskDue(right)
            var leftTime = leftDue === null ? Number.MAX_VALUE : leftDue.getTime()
            var rightTime = rightDue === null ? Number.MAX_VALUE : rightDue.getTime()
            if (leftTime !== rightTime) return leftTime - rightTime

            var urgencyDifference = Number(right.urgency || 0) - Number(left.urgency || 0)
            if (urgencyDifference !== 0) return urgencyDifference
            return String(left.description || "").localeCompare(String(right.description || ""))
        })
        return sorted
    }
}
