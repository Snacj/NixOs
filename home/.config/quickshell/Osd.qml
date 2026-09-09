import Quickshell
import Quickshell.Hyprland
import QtQuick

// Volume / brightness on-screen display. Sits just above the bar on whichever
// monitor has focus, and never takes input.
PanelWindow {
    id: root

    required property var modelData

    readonly property bool focusedHere: Hyprland.monitorFor(root.screen) === Hyprland.focusedMonitor
    readonly property bool shown: OsdController.visible && root.focusedHere

    property real progress: 0

    screen: root.modelData
    color: "transparent"
    visible: root.progress > 0
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore

    // Purely informational, so it must never eat a click.
    mask: Region {}

    anchors.bottom: true
    margins.bottom: Theme.barHeight + 28

    implicitWidth: 240
    implicitHeight: 54

    onShownChanged: root.progress = root.shown ? 1 : 0

    Behavior on progress {
        NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutQuad }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.popup
        border.color: Theme.borderStrong
        border.width: 1

        opacity: root.progress
        transform: Translate { y: (1 - root.progress) * 6 }

        Column {
            anchors {
                fill: parent
                margins: 12
            }
            spacing: 10

            Item {
                width: parent.width
                height: osdLabel.implicitHeight

                PopupHeading {
                    id: osdLabel
                    anchors.left: parent.left
                    text: OsdController.label
                }

                Text {
                    anchors.right: parent.right
                    text: OsdController.readout
                    color: OsdController.kind === "volume" && OsdController.muted
                        ? Theme.dim : Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            Rectangle {
                width: parent.width
                height: 4
                color: Theme.border

                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width: parent.width * Math.max(0, Math.min(1, OsdController.value))
                    color: OsdController.kind === "volume" && OsdController.muted
                        ? Theme.dim : Theme.accent

                    Behavior on width {
                        NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutQuad }
                    }
                }
            }
        }
    }
}
