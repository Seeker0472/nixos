//@ pragma UseQApplication
//@ pragma IconTheme breeze-dark

import QtQuick 6.0
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData
                id: barWindow
                screen: modelData
                anchors {
                    top: true
                    left: true
                    right: true
                }
                color: "transparent"
                implicitHeight: 46
                exclusiveZone: 46
                aboveWindows: true

                WlrLayershell.namespace: "niri-shell-bar"
                WlrLayershell.layer: WlrLayer.Top

                Bar {
                    anchors.fill: parent
                    screen: modelData
                    panelWindow: barWindow
                }

                PopupWindow {
                    id: controlPopup
                    property bool closeAnimationActive: false
                    property bool hasOpened: false
                    readonly property bool requestedVisible: ShellState.popupOpen && ShellState.popupScreen === modelData
                    anchor.window: barWindow
                    anchor.rect.x: Math.max(12, barWindow.width - width - 18)
                    anchor.rect.y: barWindow.height + 8
                    visible: requestedVisible || closeAnimationActive
                    implicitWidth: 430
                    implicitHeight: 540
                    color: "transparent"
                    grabFocus: true

                    onRequestedVisibleChanged: {
                        if (requestedVisible) {
                            hasOpened = true
                            closeAnimationActive = false
                            closeTimer.stop()
                            closeAnimation.stop()
                            popupContent.opacity = 0
                            popupContent.scale = 0.96
                            openAnimation.restart()
                        } else if (hasOpened) {
                            // A screen change should not leave two popups visible;
                            // only a real close gets the exit animation.
                            if (ShellState.popupOpen) {
                                openAnimation.stop()
                                closeAnimation.stop()
                                closeAnimationActive = false
                                popupContent.opacity = 0
                                popupContent.scale = 0.96
                            } else {
                                openAnimation.stop()
                                closeAnimationActive = true
                                closeAnimation.restart()
                                closeTimer.restart()
                            }
                        }
                    }

                    ParallelAnimation {
                        id: openAnimation
                        NumberAnimation {
                            target: popupContent
                            property: "opacity"
                            to: 1
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: popupContent
                            property: "scale"
                            to: 1
                            duration: 220
                            easing.type: Easing.OutBack
                        }
                    }

                    ParallelAnimation {
                        id: closeAnimation
                        NumberAnimation {
                            target: popupContent
                            property: "opacity"
                            to: 0
                            duration: 140
                            easing.type: Easing.InCubic
                        }
                        NumberAnimation {
                            target: popupContent
                            property: "scale"
                            to: 0.97
                            duration: 140
                            easing.type: Easing.InCubic
                        }
                    }

                    Timer {
                        id: closeTimer
                        interval: 150
                        repeat: false
                        onTriggered: controlPopup.closeAnimationActive = false
                    }

                    ControlPopup {
                        id: popupContent
                        anchors.fill: parent
                        transformOrigin: Item.TopRight
                        page: ShellState.popupPage
                        screen: modelData
                        parentWindow: barWindow
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "shell"

        function toggle(): void {
            ShellState.toggleControlCenter(ShellState.preferredScreen())
        }

        function open(page: string): void {
            ShellState.popupPage = page
            ShellState.popupScreen = ShellState.preferredScreen()
            ShellState.popupOpen = true
        }

        function close(): void {
            ShellState.closePopup()
        }
    }
}
