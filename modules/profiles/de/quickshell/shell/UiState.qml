pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var now: systemClock.date
    property int calendarMonth: (new Date()).getMonth()
    property int calendarYear: (new Date()).getFullYear()
    property string popupPage: "overview"
    property bool popupOpen: false
    property var popupScreen: null
    property bool idleInhibited: false
    property bool clockAlternate: false

    readonly property string calendarTitle: Qt.formatDate(
        new Date(root.calendarYear, root.calendarMonth, 1), "MMMM yyyy"
    )

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
        enabled: true
    }

    function preferredScreen() {
        return NiriState.preferredScreen()
    }

    function togglePopup(page, screen) {
        if (root.popupOpen && root.popupPage === page && (!screen || root.popupScreen === screen)) {
            root.closePopup()
            return
        }
        if (page === "calendar" && !root.popupOpen) root.resetCalendar()
        root.popupPage = page || "overview"
        root.popupScreen = screen || root.preferredScreen()
        root.popupOpen = true
    }

    function toggleControlCenter(screen) {
        if (root.popupOpen) root.closePopup()
        else root.togglePopup("overview", screen || root.preferredScreen())
    }

    function closePopup() {
        root.popupOpen = false
    }

    function resetCalendar() {
        root.calendarMonth = root.now.getMonth()
        root.calendarYear = root.now.getFullYear()
    }

    function shiftCalendar(delta) {
        var next = new Date(root.calendarYear, root.calendarMonth + Number(delta), 1)
        root.calendarMonth = next.getMonth()
        root.calendarYear = next.getFullYear()
    }

    function toggleClockFormat() {
        root.clockAlternate = !root.clockAlternate
    }

    function isBedtime() {
        var hour = root.now.getHours()
        return hour >= 22 || hour < 6
    }
}
