import QtQuick
import QtTest
import "../shell/FanLogic.js" as FanLogic

TestCase {
    name: "FanLogic"

    function test_rpmAndPwmFormatting() {
        compare(FanLogic.rpmLabel(608), "608 RPM")
        compare(FanLogic.rpmLabel(null), "-- RPM")
        compare(FanLogic.pwmPercent(64), 25)
        compare(FanLogic.pwmPercent(255), 100)
    }

    function test_cpuTemperatureGapIsPreserved() {
        var original = { zeroRpm: false, minPwm: 96, startTemp: 55, fullTemp: 80 }
        var raised = FanLogic.withSetting(original, "cpu", "startTemp", 65)
        compare(raised.startTemp, 65)
        compare(raised.fullTemp, 80)

        var lowered = FanLogic.withSetting(original, "cpu", "fullTemp", 70)
        compare(lowered.startTemp, 55)
        compare(lowered.fullTemp, 70)
        compare(original.fullTemp, 80)
    }

    function test_groupSpecificPwmLimits() {
        var settings = { zeroRpm: false, minPwm: 96, startTemp: 50, fullTemp: 80 }
        compare(FanLogic.withSetting(settings, "case", "minPwm", 200).minPwm, 128)
        compare(FanLogic.withSetting(settings, "cpu", "minPwm", 200).minPwm, 160)
    }
}
