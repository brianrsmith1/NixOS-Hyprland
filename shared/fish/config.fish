if status is-interactive
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    set -gx PAGER less
    fish_add_path ~/.local/bin
    starship init fish | source
    zoxide init fish | source
    alias ll 'eza -lah --group-directories-first'
    alias ls eza
    alias cat bat
    alias grep rg
end
