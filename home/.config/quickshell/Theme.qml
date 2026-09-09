pragma Singleton

import Quickshell
import QtQuick

// Single source of truth for colour and metrics.
//
// The design follows the Hyprland config: rounding 0, gaps 0, sharp edges.
// Nothing here rounds a corner or floats a panel; hierarchy comes from
// contrast, spacing and one accent colour instead.
Singleton {
    // -- surfaces ---------------------------------------------------------
    readonly property color background:    "#2b2b2b"
    readonly property color surface:       "#343434"  // module hover
    readonly property color surfaceActive: "#3d3d3d"  // module with popup open
    readonly property color popup:         "#1f1f1f"
    readonly property color popupRaised:   "#292929"  // rows inside a popup
    readonly property color border:        "#3a3a3a"
    readonly property color borderStrong:  "#4a4a4a"

    // -- text -------------------------------------------------------------
    readonly property color foreground: "#e0e0e0"
    readonly property color module:     "#987654"
    readonly property color dim:        "#6a6a6a"
    readonly property color dimHover:   "#b0b0b0"

    // -- semantic ---------------------------------------------------------
    readonly property color accent:   "#d8b64a"  // matches the Hyprland active border
    readonly property color critical: "#9e6b6b"
    readonly property color good:     "#6b9e78"
    readonly property color info:     "#add8e6"

    // -- calendar ---------------------------------------------------------
    readonly property color calMonth:   "#8a8a8a"
    readonly property color calDay:     "#6b9e78"
    readonly property color calWeek:    "#add8e6"
    readonly property color calWeekday: "#ffcc66"
    readonly property color calToday:   "#9e6b6b"

    // -- type -------------------------------------------------------------
    readonly property string fontFamily: "BigBlueTerm437 Nerd Font"
    readonly property int fontSize: 12
    readonly property int fontSizeSmall: 11

    // -- metrics ----------------------------------------------------------
    readonly property int barHeight: 26
    readonly property int modulePadding: 10
    readonly property int indicatorHeight: 2   // underline under active modules
    readonly property int popupPadding: 12
    readonly property int popupGap: 6          // distance from the bar
    readonly property int rowHeight: 26
    readonly property int panelWidth: 280

    // -- motion -----------------------------------------------------------
    // Short and uniform: the bar should feel immediate, not animated.
    readonly property int durFast: 100
    readonly property int durNormal: 150
    readonly property int durSlow: 220
}
