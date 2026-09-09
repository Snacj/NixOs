pragma Singleton

import Quickshell

// Tracks the one popup that is allowed to be open at a time, so clicking
// straight from one bar module to another swaps panels instead of needing a
// dismissing click in between.
Singleton {
    id: root

    property var current: null

    function opened(popup) {
        if (root.current && root.current !== popup)
            root.current.open = false;
        root.current = popup;
    }

    function closed(popup) {
        if (root.current === popup)
            root.current = null;
    }

    function closeAll() {
        if (root.current) {
            root.current.open = false;
            root.current = null;
        }
    }
}
