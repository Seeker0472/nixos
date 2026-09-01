pragma ComponentBehavior: Bound

//@ pragma UseQApplication
//@ pragma IconTheme breeze-dark

import QtQuick 6.0
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    id: root

    TooltipPopup { }

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
                focusable: controlPopup.requestedVisible

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
                    readonly property bool requestedVisible: UiState.popupOpen && UiState.popupScreen === modelData
                    anchor.window: barWindow
                    anchor.rect.x: Math.max(12, barWindow.width - width - 18)
                    anchor.rect.y: barWindow.height + 8
                    anchor.adjustment: PopupAdjustment.All
                    visible: requestedVisible || closeAnimationActive
                    implicitWidth: 430
                    implicitHeight: 540
                    color: "transparent"
                    // PopupWindow only applies grabFocus when it is shown. Keep
                    // it enabled before visible changes so text inputs can
                    // receive keyboard focus reliably on Wayland.
                    grabFocus: true

                    function resetContent() {
                        if (!popupLoader.item) return
                        popupLoader.item.opacity = 0
                        popupLoader.item.scale = 0.96
                    }

                    function startOpenAnimation() {
                        if (!popupLoader.item) return
                        resetContent()
                        openAnimation.restart()
                    }

                    onRequestedVisibleChanged: {
                        if (requestedVisible) {
                            hasOpened = true
                            closeAnimationActive = false
                            closeTimer.stop()
                            closeAnimation.stop()
                            startOpenAnimation()
                        } else if (hasOpened) {
                            // A screen change should not leave two popups visible;
                            // only a real close gets the exit animation.
                            if (UiState.popupOpen) {
                                openAnimation.stop()
                                closeAnimation.stop()
                                closeAnimationActive = false
                                resetContent()
                            } else {
                                openAnimation.stop()
                                closeAnimationActive = true
                                closeAnimation.restart()
                                closeTimer.restart()
                            }
                        }
                    }

                    onVisibleChanged: {
                        // PopupWindow can dismiss itself when focus is grabbed
                        // and the user clicks outside. Keep the singleton state
                        // as the source of truth in that case.
                        if (!visible && requestedVisible) ShellState.closePopup()
                    }

                    ParallelAnimation {
                        id: openAnimation
                        NumberAnimation {
                            target: popupLoader.item
                            property: "opacity"
                            to: 1
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: popupLoader.item
                            property: "scale"
                            to: 1
                            duration: 220
                            easing.type: Easing.OutBack
                        }
                    }

                    ParallelAnimation {
                        id: closeAnimation
                        NumberAnimation {
                            target: popupLoader.item
                            property: "opacity"
                            to: 0
                            duration: 140
                            easing.type: Easing.InCubic
                        }
                        NumberAnimation {
                            target: popupLoader.item
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

                    Loader {
                        id: popupLoader
                        anchors.fill: parent
                        active: controlPopup.requestedVisible || controlPopup.closeAnimationActive
                        sourceComponent: Component {
                            ControlPopup {
                                anchors.fill: parent
                                transformOrigin: Item.TopRight
                                page: UiState.popupPage
                                screen: modelData
                                parentWindow: barWindow
                            }
                        }
                        onLoaded: if (controlPopup.requestedVisible) controlPopup.startOpenAnimation()
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "shell"

        function toggle(): void {
            UiState.toggleControlCenter(NiriState.preferredScreen())
        }

        function open(page: string): void {
            UiState.popupPage = page
            UiState.popupScreen = NiriState.preferredScreen()
            UiState.popupOpen = true
        }

        function close(): void {
            UiState.closePopup()
        }
    }
}
