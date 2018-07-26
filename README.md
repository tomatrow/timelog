# timelog

A time sheet that leverages ledger.

### Usage:

`timelog --in --project='general:specific' --note='Starting for a time'`  
`timelog --out --project='general:specific' --note='Stopping for a time'`  
`timelog -b -- -p 'since today`

### Commands:

help    - show this help  
balance - show balance via ledger  
list    - list all projects  
edit    - edit in terminal editor  
visual  - edit in visual editor  
cat     - cat timelog file  
file    - show timelog file name  
active  - show active project  
recent  - show most recently closed   project  
switch  - move to a new project instantly
in      - clock into project or last   project  
out     - clock out of project  
project - specify project for clocking  
note    - add note to clocking  

### Acknowledgments:

Used `sed`/`awk` expresions from [`t`](https://github.com/nuex/t) by nuex

### Installation:

Clone and move `timelog.fish` into your fish function directory at `~/.config/fish/functions/`.

For completions, add `completions.fish` with the name `timelog.fish` to `.config/fish/completions`
