pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick

// Decides when the on-screen display appears and what it says.
//
// Volume is picked up straight from Pipewire, so the OSD shows for any change
// whatever caused it — media keys, pavucontrol, an application. Brightness has
// no such signal, so the Hyprland brightness binds poke us over IPC after
// running brightnessctl; if the shell is not running the keys still work, they
// just show nothing.
Singleton {
    id: root

    readonly property int timeout: 1600

    property string kind: ""       // "volume" | "brightness"
    property bool visible: false

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: root.sink?.audio?.volume ?? 0
    readonly property bool muted: root.sink?.audio?.muted ?? false

    // The initial values arrive during startup; showing an OSD for those would
    // flash the display on every login.
    property bool armed: false

    readonly property real value: root.kind === "brightness"
        ? Brightness.percent / 100
        : root.volume

    readonly property string label: root.kind === "brightness" ? "BRIGHTNESS" : "VOLUME"

    readonly property string readout: root.kind === "volume" && root.muted
        ? "muted"
        : Math.round(root.value * 100) + "%"

    function show(kind) {
        if (!root.armed)
            return;

        root.kind = kind;
        root.visible = true;
        hideTimer.restart();
    }

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    onVolumeChanged: root.show("volume")
    onMutedChanged: root.show("volume")

    IpcHandler {
        target: "osd"

        function brightness(): void {
            Brightness.refresh();
            root.show("brightness");
        }

        function volume(): void {
            root.show("volume");
        }
    }

    Timer {
        id: hideTimer
        interval: root.timeout
        onTriggered: root.visible = false
    }

    Timer {
        interval: 1500
        running: true
        onTriggered: root.armed = true
    }
}
