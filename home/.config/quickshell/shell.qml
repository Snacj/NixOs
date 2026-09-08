//@ pragma UseQApplication

import Quickshell

// Bottom bar, one instance per monitor. Replaces the previous waybar setup;
// the old config is kept at home/waybar.nix.bak.
ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }
}
