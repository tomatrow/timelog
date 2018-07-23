# Add this file with the name `timelog.fish` to `.config/fish/completions`
complete -c 'timelog' -s 'p' -l 'project' -a (timelog -l | string split '\n' | string join ' ')
