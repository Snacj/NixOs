import Quickshell
import Quickshell.Hyprland
import QtQuick

// A click-to-open panel anchored above a bar module.
//
// Unlike the hover tooltips this replaces, the contents stay put and can be
// interacted with: the focus grab keeps it open until you click outside it,
// press Escape, or open a different module's panel.
PopupWindow {
    id: root

    required property Item anchorItem
    // Windows that may be clicked without dismissing the popup. The bar is
    // passed in so that clicking a different module swaps panels directly.
    property var passthroughWindows: []
    property bool open: false

    default property alias content: body.data

    // 0 closed, 1 open. Drives the fade so the window can stay mapped until
    // the closing animation has finished.
    property real progress: 0

    anchor {
        item: root.anchorItem
        edges: Edges.Top
        gravity: Edges.Top
        margins.bottom: Theme.popupGap
        // Keep panels on screen when their module sits near a screen edge.
        adjustment: PopupAdjustment.SlideX
    }

    implicitWidth: body.implicitWidth + Theme.popupPadding * 2
    implicitHeight: body.implicitHeight + Theme.popupPadding * 2
    color: "transparent"
    visible: root.progress > 0

    onOpenChanged: {
        if (root.open)
            PopupManager.opened(root);
        else
            PopupManager.closed(root);

        root.progress = root.open ? 1 : 0;
    }

    Behavior on progress {
        NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutQuad }
    }

    Component.onDestruction: PopupManager.closed(root)

    HyprlandFocusGrab {
        active: root.open
        windows: [root].concat(root.passthroughWindows)
        onCleared: root.open = false
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.popup
        border.color: Theme.borderStrong
        border.width: 1

        opacity: root.progress
        // Rises into place; 4px reads as motion without feeling slow. Applied as
        // a transform because y would fight anchors.fill.
        transform: Translate { y: (1 - root.progress) * 4 }

        focus: true
        Keys.onEscapePressed: root.open = false

        Item {
            id: body
            anchors.centerIn: parent
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }
}
