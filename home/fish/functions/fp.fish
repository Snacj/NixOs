function fp --wraps='fzf --preview="cat {}" | xargs -r nvim' --description 'alias fp=fzf --preview="cat {}" | xargs -r nvim'
  fzf --preview="cat {}" | xargs -r nvim $argv
        
end
