import Quickshell
import QtQuick

// Centre clock. Left click toggles the short format, hovering shows the
// calendar, matching the waybar clock module's format-alt / tooltip.
MouseArea {
    id: root

    property bool shortFormat: false

    implicitWidth: label.implicitWidth + 20
    height: Theme.barHeight
    hoverEnabled: true

    onClicked: root.shortFormat = !root.shortFormat

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, root.shortFormat ? "HH:mm" : "dddd | HH:mm | dd MMMM")
        color: Theme.accent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    Tooltip {
        target: root
        active: root.containsMouse

        Calendar {
            today: clock.date
        }
    }
}
