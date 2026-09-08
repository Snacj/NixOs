import Quickshell
import Quickshell.Hyprland
import QtQuick

// Persistent workspaces 1-9, all outputs, like the waybar hyprland/workspaces
// module: dim when they hold no windows, accent when occupied, underlined when
// focused.
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

            implicitWidth: label.implicitWidth + 8
            height: Theme.barHeight
            hoverEnabled: true

            onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + button.workspaceId + " })")
            onWheel: event => Hyprland.dispatch("hl.dsp.focus({ workspace = \"e" + (event.angleDelta.y > 0 ? "-1" : "+1") + "\" })")

            Text {
                id: label
                anchors.centerIn: parent
                text: button.workspaceId
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                color: button.occupied || button.focused ? Theme.accent
                     : button.containsMouse ? Theme.dimHover
                     : Theme.dim

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                color: Theme.accent
                visible: button.focused
            }
        }
    }
}
