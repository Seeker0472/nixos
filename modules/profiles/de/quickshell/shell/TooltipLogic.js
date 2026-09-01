function isEligible(request) {
    return request && request.owner !== null && request.owner !== undefined &&
        request.target !== null && request.target !== undefined &&
        String(request.text || "").length > 0 &&
        (Boolean(request.hovered) || Boolean(request.focused)) &&
        !Boolean(request.dismissed)
}

function newer(request, candidate) {
    return candidate === null || Number(request.sequence || 0) > Number(candidate.sequence || 0)
}

function select(requests) {
    var pointerCandidate = null
    var focusCandidate = null

    for (var i = 0; i < requests.length; i++) {
        var request = requests[i]
        if (!isEligible(request)) continue

        if (request.hovered && newer(request, pointerCandidate)) pointerCandidate = request
        if (request.focused && newer(request, focusCandidate)) focusCandidate = request
    }

    return pointerCandidate || focusCandidate
}

function dismissedAfterUpdate(previous, target, hovered, focused) {
    if (!previous || !previous.dismissed) return false
    if (previous.target !== target) return false
    if (!hovered && !focused) return false
    // A new pointer entry is a fresh hover, even if keyboard focus remains.
    if (hovered && !previous.hovered) return false
    return true
}
