import QtQuick

// Month grid. Unlike the waybar calendar this replaces, the displayed month is
// independent of today's date so the panel can be paged through.
//
// The month is tracked as an offset from the current one rather than as a
// year/month pair, so "are we looking at this month" is a fact rather than a
// comparison that has to stay in sync.
Column {
    id: root

    property date today: new Date()
    property int offset: 0

    readonly property bool atCurrentMonth: root.offset === 0
    readonly property date shown: new Date(root.today.getFullYear(),
                                           root.today.getMonth() + root.offset, 1)

    spacing: 8

    function step(months) {
        root.offset += months;
    }

    function reset() {
        root.offset = 0;
    }

    function isoWeek(date) {
        const d = new Date(date.getFullYear(), date.getMonth(), date.getDate());
        d.setDate(d.getDate() - ((d.getDay() + 6) % 7) + 3);
        const firstThursday = new Date(d.getFullYear(), 0, 4);
        firstThursday.setDate(firstThursday.getDate() - ((firstThursday.getDay() + 6) % 7) + 3);
        return 1 + Math.round((d.getTime() - firstThursday.getTime()) / 604800000);
    }

    // Flat list of 8 columns per row: Mon-Sun plus the ISO week number.
    readonly property var cells: {
        const year = root.shown.getFullYear();
        const month = root.shown.getMonth();

        const out = [];
        const weekdays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];
        for (let i = 0; i < weekdays.length; i++)
            out.push({ label: weekdays[i], kind: "weekday" });
        out.push({ label: "", kind: "week" });

        const first = new Date(year, month, 1);
        const offset = (first.getDay() + 6) % 7;
        const days = new Date(year, month + 1, 0).getDate();
        const todayDate = root.atCurrentMonth ? root.today.getDate() : -1;

        let day = 1 - offset;
        while (day <= days) {
            for (let i = 0; i < 7; i++, day++) {
                if (day < 1 || day > days)
                    out.push({ label: "", kind: "day" });
                else
                    out.push({ label: String(day), kind: day === todayDate ? "today" : "day" });
            }
            const monday = Math.min(Math.max(day - 7, 1), days);
            out.push({ label: "W" + root.isoWeek(new Date(year, month, monday)), kind: "week" });
        }
        return out;
    }

    // Header: month name with paging arrows. Clicking the name returns to the
    // current month.
    Item {
        width: grid.width
        height: monthLabel.implicitHeight + 4

        MouseArea {
            id: prev
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            implicitWidth: 16
            implicitHeight: parent.height
            hoverEnabled: true
            onClicked: root.step(-1)

            Text {
                anchors.centerIn: parent
                text: "‹"
                color: prev.containsMouse ? Theme.accent : Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }

        MouseArea {
            id: monthButton
            anchors.centerIn: parent
            implicitWidth: monthLabel.implicitWidth + 12
            implicitHeight: parent.height
            hoverEnabled: true
            onClicked: root.reset()

            Text {
                id: monthLabel
                anchors.centerIn: parent
                text: Qt.formatDate(root.shown, "MMMM yyyy")
                color: root.atCurrentMonth ? Theme.calMonth
                     : monthButton.containsMouse ? Theme.accent
                     : Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: true
            }
        }

        MouseArea {
            id: next
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            implicitWidth: 16
            implicitHeight: parent.height
            hoverEnabled: true
            onClicked: root.step(1)

            Text {
                anchors.centerIn: parent
                text: "›"
                color: next.containsMouse ? Theme.accent : Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }
    }

    // Wrapped so the wheel handler can cover exactly the grid.
    Item {
        width: grid.width
        height: grid.height

        Grid {
            id: grid

            columns: 8
            columnSpacing: 6
            rowSpacing: 3

            Repeater {
                model: root.cells

                // The cell is an Item rather than a bare Text so the marker for
                // today paints under the digits with unambiguous ordering.
                Item {
                    id: cell

                    required property var modelData

                    implicitWidth: cell.modelData.kind === "week" ? weekMetrics.width : dayMetrics.width
                    implicitHeight: dayMetrics.height

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -2
                        color: Theme.calToday
                        visible: cell.modelData.kind === "today"
                    }

                    Text {
                        anchors.fill: parent
                        text: cell.modelData.label
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                        color: cell.modelData.kind === "weekday" ? Theme.calWeekday
                             : cell.modelData.kind === "week" ? Theme.calWeek
                             : cell.modelData.kind === "today" ? Theme.popup
                             : Theme.calDay
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: event => root.step(event.angleDelta.y > 0 ? -1 : 1)
        }
    }

    TextMetrics {
        id: dayMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
        text: "88"
    }

    TextMetrics {
        id: weekMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
        text: "W88"
    }
}
