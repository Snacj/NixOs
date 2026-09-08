import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import QtQuick

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

    readonly property PwNode sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: [bar.sink]
    }

    Process {
        id: mixer
        command: ["pavucontrol"]
    }

    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: 1
        color: Theme.border
    }

    Workspaces {
        monitor: Hyprland.monitorFor(bar.screen)
        anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
    }

    Clock {
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
    }

    Row {
        anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
        spacing: 0

        // pulseaudio
        BarModule {
            readonly property real volume: bar.sink?.audio?.volume ?? 0
            readonly property bool muted: bar.sink?.audio?.muted ?? false

            text: muted ? "muted" : "vol " + Math.round(volume * 100) + "%"
            textColor: muted ? Theme.dim : Theme.module
            hoverColor: Theme.accent
            tooltipText: bar.sink?.description ?? ""

            onClicked: mixer.running = true
            onWheel: event => {
                if (!bar.sink?.audio)
                    return;
                const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
                bar.sink.audio.volume = Math.max(0, Math.min(1, bar.sink.audio.volume + step));
            }
        }

        // network
        BarModule {
            text: SysInfo.networkText
            textColor: SysInfo.networkConnected ? Theme.module : Theme.dim
            hoverColor: Theme.accent
            tooltipText: SysInfo.networkTooltip
        }

        // cpu
        BarModule {
            text: "cpu " + SysInfo.cpuUsage + "%"
        }

        // memory
        BarModule {
            text: "mem " + SysInfo.memUsed.toFixed(1) + "/" + SysInfo.memTotal.toFixed(1) + " GB"
            tooltipText: Math.round(100 * SysInfo.memUsed / Math.max(SysInfo.memTotal, 1)) + "%"
        }

        // battery, on machines that have one
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

        Tray {
            bar: bar
        }
    }
}
