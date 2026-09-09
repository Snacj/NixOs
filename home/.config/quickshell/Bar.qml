import Quickshell
import Quickshell.Hyprland
import QtQuick

// Bottom bar, one instance per monitor.
//
// Layout is three groups: workspaces on the left, clock in the centre, and
// system state on the right. The right-hand group is separated by hairlines
// into audio / network / resources / notifications / tray, so related readings
// sit together instead of running into one strip of text.
PanelWindow {
    id: bar

    required property var modelData

    screen: bar.modelData
    color: Theme.background
    implicitHeight: Theme.barHeight

    anchors {
        left: true
        right: true
        bottom: true
    }

    // Clicking empty bar space dismisses whichever panel is open.
    MouseArea {
        anchors.fill: parent
        onClicked: PopupManager.closeAll()
    }

    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: 1
        color: Theme.border
    }

    Workspaces {
        monitor: Hyprland.monitorFor(bar.screen)
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
    }

    Clock {
        barWindow: bar
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
    }

    Row {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        spacing: 0

        Audio {
            barWindow: bar
        }

        Divider {}

        Network {
            barWindow: bar
        }

        Divider {}

        BarModule {
            text: "cpu " + SysInfo.cpuUsage + "%"
            textColor: SysInfo.cpuUsage >= 90 ? Theme.critical : Theme.module
            tooltipText: SysInfo.cpuUsage + "% across all cores"
        }

        BarModule {
            readonly property real fraction: SysInfo.memUsed / Math.max(SysInfo.memTotal, 1)

            text: "mem " + SysInfo.memUsed.toFixed(1) + "/" + SysInfo.memTotal.toFixed(1) + " GB"
            textColor: fraction >= 0.9 ? Theme.critical : Theme.module
            tooltipText: Math.round(100 * fraction) + "% used"
        }

        // Battery, on machines that have one.
        BarModule {
            readonly property bool charging: SysInfo.batteryStatus === "Charging"
            readonly property bool plugged: SysInfo.batteryStatus === "Full"
                || SysInfo.batteryStatus === "Not charging"

            visible: SysInfo.batteryPresent
            width: visible ? implicitWidth : 0

            text: "bat " + SysInfo.batteryPercent + "%" + (charging ? " chr" : plugged ? " plg" : "")
            textColor: charging || plugged ? Theme.module
                     : SysInfo.batteryPercent <= 15 ? Theme.critical
                     : SysInfo.batteryPercent <= 30 ? Theme.accent
                     : Theme.module
            tooltipText: {
                const watts = SysInfo.batteryWatts.toFixed(1) + "W";
                if (SysInfo.batterySecondsLeft <= 0)
                    return watts;
                const hours = Math.floor(SysInfo.batterySecondsLeft / 3600);
                const minutes = Math.round((SysInfo.batterySecondsLeft % 3600) / 60);
                return hours + "h " + minutes + "m " + (charging ? "until full" : "left") + ", " + watts;
            }
        }

        Divider {}

        NotificationCenter {
            barWindow: bar
        }

        Divider {
            visible: tray.visible
        }

        Tray {
            id: tray
            barWindow: bar
        }
    }
}
