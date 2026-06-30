function fish_prompt
    set_color brblack
    printf "[%s] " (date "+%H:%M")

    set_color cyan
    printf "%s" $USER

    set_color normal
    printf ":"

    set_color yellow
    printf "%s" (basename (pwd))

    set_color normal

    # Git branch
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set branch (git branch --show-current 2>/dev/null)

        if test -n "$branch"
            set_color green
            printf " ("
            printf "%s" $branch
            printf ")"
        end
    end

    set_color red

    printf " | "
end
