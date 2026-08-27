pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string fontFamily: "Maple Mono NF CN"

    readonly property color background: "#171722"
    readonly property color backgroundElevated: "#1f1f2d"
    readonly property color surface: "#28283a"
    readonly property color surfaceStrong: "#35354b"
    readonly property color text: "#f1f2f8"
    readonly property color muted: "#a6adc8"
    readonly property color subtle: "#6c7086"
    readonly property color accent: "#f5c2e7"
    readonly property color accentAlt: "#89dceb"
    readonly property color success: "#a6e3a1"
    readonly property color warning: "#f9e2af"
    readonly property color danger: "#f38ba8"
    readonly property int radius: 12
    readonly property int smallRadius: 8
    readonly property int controlHeight: 30
    readonly property int fieldHeight: 34
    readonly property int bodyFontSize: 12
    readonly property int smallFontSize: 10
    readonly property int iconFontSize: 17
    readonly property int animationFast: 140
    readonly property int animationNormal: 220

    function tint(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }
}
