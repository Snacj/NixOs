pragma Singleton

import Quickshell
import QtQuick

// Colours and metrics lifted from the old Waybar stylesheet.
Singleton {
    readonly property color background: "#2b2b2b"
    readonly property color border:     "#3a3a3a"
    readonly property color foreground: "#e0e0e0"
    readonly property color dim:        "#6a6a6a"
    readonly property color dimHover:   "#b0b0b0"
    readonly property color accent:     "#D8B64A"
    readonly property color module:     "#987654"
    readonly property color critical:   "#9e6b6b"

    readonly property color tooltipBackground: "#1f1f1f"

    // calendar palette (waybar clock.calendar.format)
    readonly property color calMonth:   "#6a6a6a"
    readonly property color calDay:     "#6b9e78"
    readonly property color calWeek:    "#add8e6"
    readonly property color calWeekday: "#ffcc66"
    readonly property color calToday:   "#9e6b6b"

    readonly property string fontFamily: "BigBlueTerm437 Nerd Font"
    readonly property int fontSize: 12

    readonly property int barHeight: 24
    readonly property int modulePadding: 8
}
