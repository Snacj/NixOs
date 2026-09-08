import QtQuick

// Month grid used in the clock tooltip, coloured like waybar's calendar.
Column {
    id: root

    property date today: new Date()
    readonly property int year: today.getFullYear()
    readonly property int month: today.getMonth()

    spacing: 6

    function isoWeek(date) {
        const d = new Date(date.getFullYear(), date.getMonth(), date.getDate());
        d.setDate(d.getDate() - ((d.getDay() + 6) % 7) + 3);
        const firstThursday = new Date(d.getFullYear(), 0, 4);
        firstThursday.setDate(firstThursday.getDate() - ((firstThursday.getDay() + 6) % 7) + 3);
        return 1 + Math.round((d.getTime() - firstThursday.getTime()) / 604800000);
    }

    // Flat list of 8 columns per row: Mon-Sun plus the ISO week number.
    readonly property var cells: {
        const out = [];
        const weekdays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];
        for (let i = 0; i < weekdays.length; i++)
            out.push({ label: weekdays[i], kind: "weekday" });
        out.push({ label: "", kind: "week" });

        const first = new Date(root.year, root.month, 1);
        const offset = (first.getDay() + 6) % 7;
        const days = new Date(root.year, root.month + 1, 0).getDate();
        const todayDate = root.today.getDate();

        let day = 1 - offset;
        while (day <= days) {
            for (let i = 0; i < 7; i++, day++) {
                if (day < 1 || day > days)
                    out.push({ label: "", kind: "day" });
                else
                    out.push({ label: String(day), kind: day === todayDate ? "today" : "day" });
            }
            const monday = Math.min(Math.max(day - 7, 1), days);
            out.push({ label: "W" + root.isoWeek(new Date(root.year, root.month, monday)), kind: "week" });
        }
        return out;
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDate(root.today, "MMMM yyyy")
        color: Theme.calMonth
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
    }

    Grid {
        columns: 8
        columnSpacing: 6
        rowSpacing: 2

        Repeater {
            model: root.cells

            Text {
                required property var modelData

                text: modelData.label
                horizontalAlignment: Text.AlignRight
                width: modelData.kind === "week" ? weekMetrics.width : dayMetrics.width
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: true
                font.underline: modelData.kind === "today"
                color: modelData.kind === "weekday" ? Theme.calWeekday
                     : modelData.kind === "week" ? Theme.calWeek
                     : modelData.kind === "today" ? Theme.calToday
                     : Theme.calDay
            }
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
