pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Backlight level, read through brightnessctl so any backlight class works.
// Only read on demand: the level cannot change without something asking us to
// look, so there is nothing to poll.
Singleton {
    id: root

    property int percent: 0
    property bool available: false

    function refresh() {
        reader.running = true;
    }

    function parse(text) {
        // device,class,current,percent%,max
        const line = text.trim().split("\n")[0];
        if (!line)
            return;

        const fields = line.split(",");
        if (fields.length < 5)
            return;

        root.percent = parseInt(fields[3]);
        root.available = true;
    }

    Process {
        id: reader
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: root.parse(this.text)
        }
    }

    // Prime the value once at startup so the first OSD has something to show.
    Timer {
        interval: 1
        running: true
        onTriggered: root.refresh()
    }
}
