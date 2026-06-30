if status is-interactive
    # Commands to run in interactive sessions can go here
    # if type -q tmux
    #     if not test -n "$TMUX"
    #         tmux new-session -s 0xDEADBEEF; or tmux new-session
    #     end
    # end
    zoxide init fish | source
end

set fish_greeting

# Created by `pipx` on 2026-01-27 16:56:03
set PATH $PATH /home/snacj/.local/bin
