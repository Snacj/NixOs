//@ pragma UseQApplication

import Quickshell

// Three layers, each one instance per monitor:
//
//   Bar                   bottom bar, always on every screen
//   Osd                   volume / brightness display, focused screen only
//   NotificationOverlay   toast stack, focused screen only
//
// Replaces the previous waybar + mako setup; the old waybar config is kept at
// home/waybar.nix.bak.
ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    Variants {
        model: Quickshell.screens

        Osd {}
    }

    Variants {
        model: Quickshell.screens

        NotificationOverlay {}
    }
}
