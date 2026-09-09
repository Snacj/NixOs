import Quickshell
import Quickshell.Hyprland
import QtQuick

// Toast stack, top right of whichever monitor has focus. Only the cards
// themselves take input; the gaps between them stay click-through.
PanelWindow {
    id: root

    required property var modelData

    readonly property bool focusedHere: Hyprland.monitorFor(root.screen) === Hyprland.focusedMonitor

    screen: root.modelData
    color: "transparent"
    visible: root.focusedHere && Notifications.active.length > 0
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }

    margins {
        top: 8
        right: 8
    }

    implicitWidth: stack.implicitWidth
    implicitHeight: Math.max(1, stack.implicitHeight)

    mask: Region {
        item: stack
    }

    Column {
        id: stack

        anchors.right: parent.right
        spacing: 6

        add: Transition {
            NumberAnimation {
                property: "y"
                duration: Theme.durSlow
                easing.type: Easing.OutQuad
            }
        }

        move: Transition {
            NumberAnimation {
                properties: "y"
                duration: Theme.durSlow
                easing.type: Easing.OutQuad
            }
        }

        Repeater {
            model: Notifications.active

            NotificationCard {
                required property var modelData
                notification: modelData
            }
        }
    }
}
