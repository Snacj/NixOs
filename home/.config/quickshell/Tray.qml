import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

Row {
    id: root

    property var bar

    spacing: 8
    leftPadding: visible && children.length > 0 ? Theme.modulePadding : 0
    rightPadding: leftPadding

    Repeater {
        model: SystemTray.items

        MouseArea {
            id: item

            required property SystemTrayItem modelData

            implicitWidth: Theme.fontSize + 4
            height: Theme.barHeight
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: event => {
                if (event.button === Qt.LeftButton && !item.modelData.onlyMenu)
                    item.modelData.activate();
                else if (item.modelData.hasMenu)
                    item.modelData.display(root.bar, item.width / 2, 0);
            }

            IconImage {
                anchors.centerIn: parent
                implicitSize: Theme.fontSize + 2
                source: item.modelData.icon
                opacity: item.containsMouse ? 1 : 0.85
            }

            Tooltip {
                target: item
                active: item.containsMouse && item.modelData.tooltipTitle !== ""

                TooltipText {
                    text: item.modelData.tooltipTitle !== "" ? item.modelData.tooltipTitle : item.modelData.title
                }
            }
        }
    }
}
