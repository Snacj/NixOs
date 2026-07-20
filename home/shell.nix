{ config, pkgs, hostName, ... }:

{
  # Fish
  programs.fish = {
    enable = true;

    # Abbreviations
    shellAbbrs = {
      v       = "nvim";
      notes   = "nvim ~/Notes";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#${hostName}";
      gs      = "git status";
    };

    shellAliases = {
      ls   = "ls --color=auto";
      grep = "grep --color=auto";
      ll   = "ls -la --color=auto";
    };

    functions = {
      fish_greeting = "";

      fish_prompt = ''
        set_color brblack
        printf "[%s] " (date "+%H:%M")

        set_color cyan
        printf "%s" $USER

        set_color normal
        printf ":"

        set_color yellow
        printf "%s" (basename (pwd))

        set_color normal

        if git rev-parse --is-inside-work-tree >/dev/null 2>&1
            set branch (git branch --show-current 2>/dev/null)
            if test -n "$branch"
                set_color green
                printf " (%s)" $branch
            end
        end

        # Nix dev shell indicator
        if set -q IN_NIX_SHELL; or set -q DIRENV_DIR
            set_color magenta
            printf " [develop]"
        end

        set_color red
        printf " | "
      '';

      copyraw = {
        description = "Copy raw file content to clipboard using wl-copy";
        body = ''
          if test (count $argv) -gt 0
            cat $argv | wl-copy
          else
            cat | wl-copy
          end
        '';
      };

      f = {
        description = "Fuzzy find files and open in nvim";
        body = "fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs -o nvim $argv";
      };

      fp = {
        description = "Fuzzy find with preview and open in nvim";
        body = ''fzf --preview="cat {}" | xargs -r nvim $argv'';
      };
    };

    shellInit = ''
      fish_add_path ~/.local/bin
    '';
  };

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
