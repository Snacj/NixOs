pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// CPU / memory from /proc, network state from nmcli. Quickshell has no
// built-in service for either, so both are polled by a short shell command.
Singleton {
    id: root

    property int cpuUsage: 0
    property real memUsed: 0
    property real memTotal: 0

    property bool batteryPresent: false
    property int batteryPercent: 0
    property string batteryStatus: "Unknown"
    property real batteryWatts: 0
    property real batterySecondsLeft: 0

    property string networkText: "offline"
    property string networkTooltip: "disconnected"
    property bool networkConnected: false

    property real lastCpuTotal: 0
    property real lastCpuIdle: 0

    function parseProc(text) {
        let memAvail = 0;
        const lines = text.split("\n");

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];

            if (line.startsWith("cpu ")) {
                const parts = line.trim().split(/\s+/).slice(1).map(parseFloat);
                let total = 0;
                for (let j = 0; j < parts.length; j++)
                    total += parts[j];
                const idle = parts[3] + (parts[4] || 0);

                if (root.lastCpuTotal > 0) {
                    const dTotal = total - root.lastCpuTotal;
                    const dIdle = idle - root.lastCpuIdle;
                    if (dTotal > 0)
                        root.cpuUsage = Math.round(100 * (dTotal - dIdle) / dTotal);
                }
                root.lastCpuTotal = total;
                root.lastCpuIdle = idle;
            } else if (line.startsWith("MemTotal:")) {
                root.memTotal = parseFloat(line.split(/\s+/)[1]) / 1048576;
            } else if (line.startsWith("MemAvailable:")) {
                memAvail = parseFloat(line.split(/\s+/)[1]) / 1048576;
            }
        }

        root.memUsed = Math.max(0, root.memTotal - memAvail);
    }

    // nmcli -t escapes literal colons as "\:", so split on unescaped ones only.
    function splitFields(line) {
        const fields = [];
        let current = "";
        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            if (c === "\\" && line[i + 1] === ":") {
                current += ":";
                i++;
            } else if (c === ":") {
                fields.push(current);
                current = "";
            } else {
                current += c;
            }
        }
        fields.push(current);
        return fields;
    }

    function parseNetwork(text) {
        const blocks = text.split("@@");
        const devices = blocks[0].trim().split("\n");
        let wifi = null;
        let ethernet = false;

        for (let i = 0; i < devices.length; i++) {
            const f = splitFields(devices[i]);
            if (f.length < 3 || f[1] !== "connected")
                continue;
            if (f[0] === "wifi" && wifi === null)
                wifi = f[2];
            else if (f[0] === "ethernet")
                ethernet = true;
        }

        if (wifi !== null) {
            const signal = blocks.length > 1 ? blocks[1].trim() : "";
            root.networkText = wifi;
            root.networkTooltip = signal !== "" ? wifi + "\n" + signal + "%" : wifi;
            root.networkConnected = true;
        } else if (ethernet) {
            root.networkText = "eth";
            root.networkTooltip = "ethernet";
            root.networkConnected = true;
        } else {
            root.networkText = "offline";
            root.networkTooltip = "disconnected";
            root.networkConnected = false;
        }
    }

    // Battery straight from sysfs, as waybar did; UPower is not running
    // on these hosts.
    function parseBattery(text) {
        const values = {};
        const lines = text.trim().split("\n");
        for (let i = 0; i < lines.length; i++) {
            const parts = lines[i].split("=");
            if (parts.length === 2)
                values[parts[0]] = parts[1];
        }

        root.batteryPresent = values.capacity !== undefined;
        if (!root.batteryPresent)
            return;

        root.batteryPercent = parseInt(values.capacity);
        root.batteryStatus = values.status || "Unknown";

        const charge = parseFloat(values.energy_now || values.charge_now || 0);
        const full = parseFloat(values.energy_full || values.charge_full || 0);
        const rate = parseFloat(values.power_now || values.current_now || 0);
        const voltage = parseFloat(values.voltage_now || 0) / 1e6;

        root.batteryWatts = values.power_now !== undefined
            ? parseFloat(values.power_now) / 1e6
            : rate / 1e6 * voltage;

        const charging = root.batteryStatus === "Charging";
        root.batterySecondsLeft = rate > 0
            ? (charging ? full - charge : charge) / rate * 3600
            : 0;
    }

    Process {
        id: procReader
        command: ["sh", "-c", "grep '^cpu ' /proc/stat; grep -E '^(MemTotal|MemAvailable):' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: root.parseProc(this.text)
        }
    }

    Process {
        id: networkReader
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device status; echo @@; nmcli -t -f IN-USE,SIGNAL device wifi list --rescan no 2>/dev/null | sed -n 's/^\\*://p'"]
        stdout: StdioCollector {
            onStreamFinished: root.parseNetwork(this.text)
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: procReader.running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: networkReader.running = true
    }

    Process {
        id: batteryReader
        command: ["sh", "-c", "b=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1); [ -n \"$b\" ] || exit 0; for f in capacity status power_now current_now voltage_now energy_now energy_full charge_now charge_full; do [ -f \"$b/$f\" ] && echo \"$f=$(cat $b/$f)\"; done"]
        stdout: StdioCollector {
            onStreamFinished: root.parseBattery(this.text)
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: batteryReader.running = true
    }
}
