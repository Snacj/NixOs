function copyraw --description 'Copy raw file content to clipboard using wl-copy'
  if test (count $argv) -gt 0
    cat $argv | wl-copy
  else
    cat | wl-copy
  end
end

