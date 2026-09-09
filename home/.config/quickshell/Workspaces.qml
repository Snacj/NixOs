import Quickshell
import Quickshell.Hyprland
import QtQuick

// Persistent workspaces 1-9. Three states rather than the two waybar showed:
// empty, holding windows, and focused — so a glance tells you both where you
// are and where there is something to go back to.
Row {
    id: root

    property HyprlandMonitor monitor: null

    spacing: 0

    Repeater {
        model: 9

        MouseArea {
            id: button

            required property int index
            readonly property int workspaceId: index + 1

            readonly property bool occupied: {
                const workspaces = Hyprland.workspaces.values;
                for (let i = 0; i < workspaces.length; i++)
                    if (workspaces[i].id === button.workspaceId)
                        return true;
                return false;
            }
            readonly property bool focused: root.monitor?.activeWorkspace?.id === button.workspaceId

            implicitWidth: Theme.barHeight
            height: Theme.barHeight
            hoverEnabled: true

            onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + button.workspaceId + " })")
            onWheel: event => Hyprland.dispatch("hl.dsp.focus({ workspace = \"e" + (event.angleDelta.y > 0 ? "-1" : "+1") + "\" })")

            Rectangle {
                anchors.fill: parent
                color: button.containsMouse ? Theme.surface : "transparent"

                Behavior on color {
                    ColorAnimation { duration: Theme.durNormal }
                }
            }

            Text {
                id: label
                anchors.centerIn: parent
                text: button.workspaceId
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                color: button.focused ? Theme.accent
                     : button.occupied ? Theme.module
                     : button.containsMouse ? Theme.dimHover
                     : Theme.dim

                Behavior on color {
                    ColorAnimation { duration: Theme.durNormal }
                }
            }

            // Empty workspaces get nothing; occupied ones get a small mark so
            // they read as populated even at a distance.
            Rectangle {
                anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 3 }
                width: 3
                height: 3
                color: Theme.module
                visible: button.occupied && !button.focused
            }

            // On the top edge, matching the modules on the right.
            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top }
                height: Theme.indicatorHeight
                color: Theme.accent
                opacity: button.focused ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: Theme.durNormal }
                }
            }
        }
    }
}
