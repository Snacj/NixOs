import Quickshell
import QtQuick

// Centre clock. Click opens the calendar, which stays open and can be paged
// through; right click switches between the long and short time format.
Item {
    id: root

    required property var barWindow

    property bool shortFormat: false

    implicitWidth: module.implicitWidth
    implicitHeight: Theme.barHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    BarModule {
        id: module

        interactive: true
        expanded: popup.open
        textColor: Theme.accent
        hoverColor: Theme.foreground
        text: Qt.formatDateTime(clock.date, root.shortFormat ? "HH:mm" : "dddd | HH:mm | dd MMMM")

        onClicked: event => {
            if (event.button === Qt.RightButton)
                root.shortFormat = !root.shortFormat;
            else
                popup.open = !popup.open;
        }
    }

    Popup {
        id: popup

        anchorItem: module
        passthroughWindows: [root.barWindow]

        // Always reopen on the current month rather than wherever it was left.
        onOpenChanged: if (popup.open) calendar.reset()

        Calendar {
            id: calendar
            today: clock.date
        }
    }
}
