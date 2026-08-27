import QtQuick
import QtTest
import "../shell/NiriLogic.js" as NiriLogic

TestCase {
    name: "NiriLogic"

    function ids(workspaces) {
        return workspaces.map(function(workspace) { return workspace.id }).join(",")
    }

    function test_sortWorkspaces() {
        var workspaces = [
            { id: 3, output: "DP-2", idx: 2 },
            { id: 2, output: "DP-1", idx: 2 },
            { id: 1, output: "DP-1", idx: 1 }
        ]
        compare(ids(NiriLogic.sortWorkspaces(workspaces)), "1,2,3")
        compare(ids(workspaces), "3,2,1")
    }

    function test_activateWorkspace() {
        var workspaces = [
            { id: 1, output: "DP-1", is_active: true, is_focused: true },
            { id: 2, output: "DP-1", is_active: false, is_focused: false },
            { id: 3, output: "DP-2", is_active: true, is_focused: false }
        ]
        var result = NiriLogic.activateWorkspace(workspaces, { id: 2, focused: true })

        verify(result.found)
        verify(!result.workspaces[0].is_active)
        verify(!result.workspaces[0].is_focused)
        verify(result.workspaces[1].is_active)
        verify(result.workspaces[1].is_focused)
        verify(result.workspaces[2].is_active)
        verify(!result.workspaces[2].is_focused)
        verify(workspaces[0].is_active)
        verify(workspaces[0].is_focused)
    }

    function test_unknownWorkspace() {
        var workspaces = [{ id: 1, output: "DP-1" }]
        var result = NiriLogic.activateWorkspace(workspaces, { id: 99, focused: true })
        verify(!result.found)
        compare(result.workspaces, workspaces)
    }
}
