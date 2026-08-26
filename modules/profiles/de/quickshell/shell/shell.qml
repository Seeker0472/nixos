//@ pragma UseQApplication

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
                implicitHeight: 52
                exclusiveZone: 52
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
                    anchor.window: barWindow
                    anchor.rect.x: Math.max(12, barWindow.width - width - 18)
                    anchor.rect.y: barWindow.height + 8
                    visible: ShellState.popupOpen && ShellState.popupScreen === modelData
                    implicitWidth: 430
                    implicitHeight: 540
                    color: "transparent"
                    grabFocus: true
                    ControlPopup {
                        anchors.fill: parent
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
