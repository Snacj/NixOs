function f --wraps='fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs -o nvim' --description 'alias f=fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs -o nvim'
  fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs -o nvim $argv
        
end
