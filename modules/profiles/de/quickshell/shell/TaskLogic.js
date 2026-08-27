.pragma library

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

function isValidDateInput(value) {
    var text = String(value || "").trim()
    if (text.length === 0) return true
    var match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(text)
    if (!match) return false
    var year = Number(match[1])
    var month = Number(match[2])
    var day = Number(match[3])
    if (year < 1000) return false
    var parsed = new Date(Date.UTC(year, month - 1, day))
    return parsed.getUTCFullYear() === year &&
        parsed.getUTCMonth() === month - 1 &&
        parsed.getUTCDate() === day
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

function countTasks(values, kind, now) {
    var start = startOfDay(now)
    var tomorrow = startOfTomorrow(now)
    var count = 0
    for (var i = 0; i < values.length; i++) {
        var due = taskDue(values[i])
        if (kind === "inbox" && due === null) count++
        else if (kind === "overdue" && due !== null && due < start) count++
        else if (kind === "today" && due !== null && due >= start && due < tomorrow) count++
        else if (kind === "upcoming" && due !== null && due >= tomorrow) count++
    }
    return count
}

function filteredTasks(values, view, now) {
    if (view === "all") return values
    var tomorrow = startOfTomorrow(now)
    return values.filter(function(task) {
        var due = taskDue(task)
        if (view === "inbox") return due === null
        if (view === "today") return due !== null && due < tomorrow
        if (view === "upcoming") return due !== null && due >= tomorrow
        return true
    })
}

function priorityRank(value) {
    if (value === "H") return 0
    if (value === "M") return 1
    if (value === "L") return 2
    return 3
}

function sortTasks(values) {
    var sorted = values.slice()
    sorted.sort(function(left, right) {
        var leftDue = taskDue(left)
        var rightDue = taskDue(right)
        var leftTime = leftDue === null ? Number.MAX_VALUE : leftDue.getTime()
        var rightTime = rightDue === null ? Number.MAX_VALUE : rightDue.getTime()
        if (leftTime !== rightTime) return leftTime - rightTime
        var priorityDifference = priorityRank(left.priority) - priorityRank(right.priority)
        if (priorityDifference !== 0) return priorityDifference
        var urgencyDifference = Number(right.urgency || 0) - Number(left.urgency || 0)
        if (urgencyDifference !== 0) return urgencyDifference
        return String(left.description || "").localeCompare(String(right.description || ""))
    })
    return sorted
}

function parseTags(value) {
    var raw = Array.isArray(value) ? value : String(value || "").split(/[,\s]+/)
    var tags = []
    for (var i = 0; i < raw.length; i++) {
        var tag = String(raw[i] || "").trim().replace(/^\+/, "")
        if (tag.length > 0 && tags.indexOf(tag) < 0) tags.push(tag)
    }
    return tags
}
