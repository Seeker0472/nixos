import QtQuick
import QtTest
import "../shell/TaskLogic.js" as TaskLogic

TestCase {
    name: "TaskLogic"

    function localDate(year, month, day, hour) {
        return new Date(year, month - 1, day, hour || 0).toISOString()
    }

    function uuids(tasks) {
        return tasks.map(function(task) { return task.uuid }).join(",")
    }

    function test_parseTaskwarriorDate() {
        compare(
            TaskLogic.parseDate("20260827T160000Z").toISOString(),
            "2026-08-27T16:00:00.000Z"
        )
        compare(TaskLogic.parseDate("not-a-date"), null)
    }

    function test_validateDateInput() {
        verify(TaskLogic.isValidDateInput(""))
        verify(TaskLogic.isValidDateInput("2028-02-29"))
        verify(!TaskLogic.isValidDateInput("2026-02-29"))
        verify(!TaskLogic.isValidDateInput("2026-13-01"))
        verify(!TaskLogic.isValidDateInput("27 August 2026"))
    }

    function test_views() {
        var now = new Date(2026, 7, 27, 12)
        var tasks = [
            { uuid: "inbox" },
            { uuid: "overdue", due: localDate(2026, 8, 26) },
            { uuid: "today", due: localDate(2026, 8, 27) },
            { uuid: "upcoming", due: localDate(2026, 8, 28) }
        ]

        compare(TaskLogic.countTasks(tasks, "inbox", now), 1)
        compare(TaskLogic.countTasks(tasks, "overdue", now), 1)
        compare(TaskLogic.countTasks(tasks, "today", now), 1)
        compare(TaskLogic.countTasks(tasks, "upcoming", now), 1)
        compare(uuids(TaskLogic.filteredTasks(tasks, "today", now)), "overdue,today")
        compare(uuids(TaskLogic.filteredTasks(tasks, "upcoming", now)), "upcoming")
    }

    function test_sortByDueThenPriority() {
        var due = localDate(2026, 8, 28)
        var tasks = [
            { uuid: "none", description: "No due", priority: "H" },
            { uuid: "low", description: "Low", due: due, priority: "L" },
            { uuid: "high", description: "High", due: due, priority: "H" },
            { uuid: "urgent", description: "Urgent", due: due, priority: "H", urgency: 10 }
        ]

        compare(uuids(TaskLogic.sortTasks(tasks)), "urgent,high,low,none")
        compare(uuids(tasks), "none,low,high,urgent")
    }

    function test_parseTags() {
        compare(TaskLogic.parseTags("+work, home work").join(","), "work,home")
        compare(TaskLogic.parseTags(["one", "+two", "one"]).join(","), "one,two")
    }
}
