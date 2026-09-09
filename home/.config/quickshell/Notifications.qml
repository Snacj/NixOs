pragma Singleton

import Quickshell
import Quickshell.Services.Notifications

// The notification daemon, replacing mako.
//
// Live notifications stay as server objects so their actions keep working;
// history is stored as plain snapshots, because the server object is destroyed
// as soon as the notification is closed.
Singleton {
    id: root

    readonly property int historyLimit: 50
    readonly property int defaultTimeout: 5000

    // Notifications currently on screen.
    readonly property var active: server.trackedNotifications?.values ?? []

    // Snapshots, newest first.
    property var history: []
    property int unread: 0

    property bool doNotDisturb: false

    function timeoutFor(notification) {
        if (notification.expireTimeout > 0)
            return notification.expireTimeout;
        // Critical notifications stay until acted on, as the spec intends.
        if (notification.urgency === NotificationUrgency.Critical)
            return 0;
        return root.defaultTimeout;
    }

    function urgencyColor(urgency) {
        return urgency === NotificationUrgency.Critical ? Theme.critical
             : urgency === NotificationUrgency.Low ? Theme.dim
             : Theme.accent;
    }

    function record(notification) {
        const entry = {
            key: notification.id,
            appName: notification.appName,
            appIcon: notification.appIcon,
            summary: notification.summary,
            body: notification.body,
            image: notification.image,
            urgency: notification.urgency,
            time: new Date()
        };

        root.history = [entry].concat(root.history).slice(0, root.historyLimit);
        root.unread += 1;
    }

    function dismissAll() {
        const notifications = root.active.slice();
        for (let i = 0; i < notifications.length; i++)
            notifications[i].dismiss();
    }

    function clearHistory() {
        root.history = [];
        root.unread = 0;
    }

    function markRead() {
        root.unread = 0;
    }

    NotificationServer {
        id: server

        keepOnReload: false

        actionsSupported: true
        actionIconsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            root.record(notification);

            // Do not disturb still records, it just does not interrupt.
            // Critical notifications are always shown.
            const silence = root.doNotDisturb
                && notification.urgency !== NotificationUrgency.Critical;

            notification.tracked = !silence;
        }
    }
}
