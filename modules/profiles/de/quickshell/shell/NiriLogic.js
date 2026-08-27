.pragma library

function copyObject(value) {
    var result = {}
    for (var key in value) result[key] = value[key]
    return result
}

function sortWorkspaces(list) {
    var sorted = Array.isArray(list) ? list.slice() : []
    sorted.sort(function(left, right) {
        var leftOutput = String((left && left.output) || "")
        var rightOutput = String((right && right.output) || "")
        if (leftOutput < rightOutput) return -1
        if (leftOutput > rightOutput) return 1
        var leftIndex = Number((left && left.idx) || 0)
        var rightIndex = Number((right && right.idx) || 0)
        if (leftIndex !== rightIndex) return leftIndex - rightIndex
        return Number((left && left.id) || 0) - Number((right && right.id) || 0)
    })
    return sorted
}

function activateWorkspace(workspaces, activationData) {
    if (!activationData) return { found: false, workspaces: workspaces }
    var workspaceId = activationData.id !== undefined ? activationData.id : activationData
    var isFocused = activationData.focused === true
    var next = workspaces.slice()
    var targetOutput = null
    for (var i = 0; i < next.length; i++) {
        if (Number(next[i].id) === Number(workspaceId)) {
            targetOutput = next[i].output
            break
        }
    }
    if (targetOutput === null && next.every(function(item) { return Number(item.id) !== Number(workspaceId) })) {
        return { found: false, workspaces: workspaces }
    }
    for (var j = 0; j < next.length; j++) {
        next[j] = copyObject(next[j])
        if (targetOutput && next[j].output === targetOutput) next[j].is_active = false
        if (isFocused) next[j].is_focused = false
        if (Number(next[j].id) === Number(workspaceId)) {
            next[j].is_active = true
            next[j].is_focused = isFocused
        }
    }
    return { found: true, workspaces: next }
}
