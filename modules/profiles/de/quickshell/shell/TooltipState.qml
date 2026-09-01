pragma Singleton

import QtQuick
import Quickshell
import "TooltipLogic.js" as TooltipLogic

Singleton {
    id: root

    property var requests: []
    property var currentOwner: null
    property Item targetItem: null
    property var targetWindow: null
    property real anchorX: 0
    property real anchorY: 0
    property real anchorWidth: 0
    property real anchorHeight: 0
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
                    request.window !== root.targetWindow || request.text !== root.text ||
                    !TooltipLogic.isEligible(request) || root.panelOpen) {
                root.reconcile()
                return
            }

            root.shown = true
        }
    }

    Timer {
        id: reconcileTimer
        interval: 0
        repeat: false
        onTriggered: root.reconcile()
    }

    onPanelOpenChanged: {
        if (root.panelOpen) root.clearCurrent()
        else root.queueReconcile()
    }

    Component.onCompleted: root.queueReconcile()

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

    function queueReconcile() {
        reconcileTimer.restart()
    }

    function clearCurrent() {
        root.stopTimer()
        root.shown = false
        root.currentOwner = null
        root.targetItem = null
        root.targetWindow = null
        root.anchorX = 0
        root.anchorY = 0
        root.anchorWidth = 0
        root.anchorHeight = 0
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

        var candidateWindow = candidate.window || null
        var ownerChanged = root.currentOwner !== candidate.owner ||
            root.targetItem !== candidate.target || root.targetWindow !== candidateWindow

        if (ownerChanged) {
            // Remove the old QQuickItem before assigning a new candidate. Workspace
            // delegates can be destroyed between hoverLeave and the next event loop.
            root.stopTimer()
            root.shown = false
            root.currentOwner = null
            root.targetItem = null
            root.targetWindow = null
            root.anchorX = 0
            root.anchorY = 0
            root.anchorWidth = 0
            root.anchorHeight = 0
        }

        root.currentOwner = candidate.owner
        root.targetItem = candidate.target
        root.targetWindow = candidate.window || null
        root.anchorX = Number(candidate.anchorX) || 0
        root.anchorY = Number(candidate.anchorY) || 0
        root.anchorWidth = Number(candidate.anchorWidth) || 0
        root.anchorHeight = Number(candidate.anchorHeight) || 0
        root.text = candidate.text
        root.pointerHovered = Boolean(candidate.hovered)
        root.focused = Boolean(candidate.focused)
        root.delay = Number(candidate.delay) || 0

        if (ownerChanged) {
            root.schedule(candidate)
        } else if (!root.shown && !showTimer.running) {
            root.schedule(candidate)
        }
    }

    function update(owner, target, windowValue, rectValue, textValue, hoveredValue, focusedValue, delayValue) {
        if (owner === null || owner === undefined) return

        var normalizedText = textValue === null || textValue === undefined ? "" : String(textValue)
        var normalizedDelay = Math.max(0, Number(delayValue) || 0)
        var normalizedHovered = Boolean(hoveredValue)
        var normalizedFocused = Boolean(focusedValue)
        var previous = root.requestFor(owner)
        var snapshot = root.snapshotTarget(windowValue, rectValue)
        var next = []

        root.sequence += 1
        for (var i = 0; i < root.requests.length; i++) {
            if (root.requests[i].owner !== owner) next.push(root.requests[i])
        }

        next.push({
            owner: owner,
            target: target,
            window: snapshot.window,
            anchorX: snapshot.x,
            anchorY: snapshot.y,
            anchorWidth: snapshot.width,
            anchorHeight: snapshot.height,
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

        if (root.currentOwner === owner && !TooltipLogic.isEligible(next[next.length - 1]))
            root.clearCurrent()

        root.queueReconcile()
    }

    function snapshotTarget(windowValue, rectValue) {
        if (windowValue === null || windowValue === undefined || !rectValue)
            return { window: null, x: 0, y: 0, width: 0, height: 0 }

        return {
            window: windowValue,
            x: Number(rectValue.x) || 0,
            y: Number(rectValue.y) || 0,
            width: Math.max(0, Number(rectValue.width) || 0),
            height: Math.max(0, Number(rectValue.height) || 0)
        }
    }

    function release(owner) {
        if (owner === null || owner === undefined) return

        var next = []
        for (var i = 0; i < root.requests.length; i++) {
            if (root.requests[i].owner !== owner) next.push(root.requests[i])
        }
        root.requests = next
        if (root.currentOwner === owner) root.clearCurrent()
        root.queueReconcile()
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
                    window: request.window,
                    anchorX: request.anchorX,
                    anchorY: request.anchorY,
                    anchorWidth: request.anchorWidth,
                    anchorHeight: request.anchorHeight,
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
        if (root.currentOwner === owner) root.clearCurrent()
        root.queueReconcile()
    }

    function dismissCurrent() {
        if (root.currentOwner !== null && root.currentOwner !== undefined) root.dismiss(root.currentOwner)
        else root.clearCurrent()
    }
}
