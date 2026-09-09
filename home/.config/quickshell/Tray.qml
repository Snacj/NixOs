import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

Row {
    id: root

    required property var barWindow

    spacing: 0
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        MouseArea {
            id: item

            required property SystemTrayItem modelData

            implicitWidth: Theme.barHeight
            height: Theme.barHeight
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: event => {
                if (event.button === Qt.LeftButton && !item.modelData.onlyMenu)
                    item.modelData.activate();
                else if (item.modelData.hasMenu)
                    item.modelData.display(root.barWindow, item.width / 2, 0);
            }

            Rectangle {
                anchors.fill: parent
                color: item.containsMouse ? Theme.surface : "transparent"

                Behavior on color {
                    ColorAnimation { duration: Theme.durNormal }
                }
            }

            IconImage {
                anchors.centerIn: parent
                implicitSize: Theme.fontSize + 2
                source: item.modelData.icon
                opacity: item.containsMouse ? 1 : 0.8

                Behavior on opacity {
                    NumberAnimation { duration: Theme.durNormal }
                }
            }

            Tooltip {
                target: item
                active: item.containsMouse

                TooltipText {
                    text: item.modelData.tooltipTitle !== ""
                        ? item.modelData.tooltipTitle
                        : item.modelData.title
                }
            }
        }
    }
}
