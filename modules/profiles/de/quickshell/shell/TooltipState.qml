pragma Singleton

import QtQuick
import Quickshell
import "TooltipLogic.js" as TooltipLogic

Singleton {
    id: root

    property var requests: []
    property var currentOwner: null
    property Item targetItem: null
    property string text: ""
    property bool pointerHovered: false
    property bool focused: false
    property int delay: 500
    property bool shown: false
    property int sequence: 0
    property int generation: 0
    property int pendingGeneration: 0
    readonly property bool panelOpen: UiState.popupOpen

    Timer {
        id: showTimer
        repeat: false
        onTriggered: {
            if (root.pendingGeneration !== root.generation) return

            var request = root.requestFor(root.currentOwner)
            if (!request || request.target !== root.targetItem ||
                    request.text !== root.text || !TooltipLogic.isEligible(request) || root.panelOpen) {
                root.reconcile()
                return
            }

            root.shown = true
        }
    }

    onPanelOpenChanged: {
        root.stopTimer()
        root.shown = false
        if (!root.panelOpen) root.reconcile()
    }

    Component.onCompleted: root.reconcile()

    function requestFor(owner) {
        if (owner === null || owner === undefined) return null
        for (var i = 0; i < root.requests.length; i++) {
            if (root.requests[i].owner === owner) return root.requests[i]
        }
        return null
    }

    function stopTimer() {
        root.generation += 1
        showTimer.stop()
    }

    function clearCurrent() {
        root.stopTimer()
        root.shown = false
        root.currentOwner = null
        root.targetItem = null
        root.text = ""
        root.pointerHovered = false
        root.focused = false
    }

    function schedule(request) {
        if (!request || root.panelOpen) return

        root.generation += 1
        root.pendingGeneration = root.generation
        showTimer.interval = Math.max(0, Number(request.delay) || 0)
        showTimer.restart()
    }

    function reconcile() {
        if (root.panelOpen) {
            root.stopTimer()
            root.shown = false
            return
        }

        var candidate = TooltipLogic.select(root.requests)
        if (!candidate) {
            root.clearCurrent()
            return
        }

        var ownerChanged = root.currentOwner !== candidate.owner || root.targetItem !== candidate.target
        root.currentOwner = candidate.owner
        root.targetItem = candidate.target
        root.text = candidate.text
        root.pointerHovered = Boolean(candidate.hovered)
        root.focused = Boolean(candidate.focused)
        root.delay = Number(candidate.delay) || 0

        if (ownerChanged) {
            root.stopTimer()
            root.shown = false
            root.schedule(candidate)
        } else if (!root.shown && !showTimer.running) {
            root.schedule(candidate)
        }
    }

    function update(owner, target, textValue, hoveredValue, focusedValue, delayValue) {
        if (owner === null || owner === undefined) return

        var normalizedText = textValue === null || textValue === undefined ? "" : String(textValue)
        var normalizedDelay = Math.max(0, Number(delayValue) || 0)
        var normalizedHovered = Boolean(hoveredValue)
        var normalizedFocused = Boolean(focusedValue)
        var previous = root.requestFor(owner)
        var next = []

        root.sequence += 1
        for (var i = 0; i < root.requests.length; i++) {
            if (root.requests[i].owner !== owner) next.push(root.requests[i])
        }

        next.push({
            owner: owner,
            target: target,
            text: normalizedText,
            hovered: normalizedHovered,
            focused: normalizedFocused,
            delay: normalizedDelay,
            sequence: root.sequence,
            dismissed: TooltipLogic.dismissedAfterUpdate(
                previous, target, normalizedHovered, normalizedFocused
            )
        })
        root.requests = next
        root.reconcile()
    }

    function release(owner) {
        if (owner === null || owner === undefined) return

        var next = []
        for (var i = 0; i < root.requests.length; i++) {
            if (root.requests[i].owner !== owner) next.push(root.requests[i])
        }
        root.requests = next
        root.reconcile()
    }

    function dismiss(owner) {
        if (owner === null || owner === undefined) return

        var next = []
        for (var i = 0; i < root.requests.length; i++) {
            var request = root.requests[i]
            if (request.owner === owner) {
                next.push({
                    owner: request.owner,
                    target: request.target,
                    text: request.text,
                    hovered: request.hovered,
                    focused: request.focused,
                    delay: request.delay,
                    sequence: request.sequence,
                    dismissed: true
                })
            } else {
                next.push(request)
            }
        }
        root.requests = next
        root.reconcile()
    }

    function dismissCurrent() {
        if (root.currentOwner !== null && root.currentOwner !== undefined) root.dismiss(root.currentOwner)
        else root.clearCurrent()
    }
}
