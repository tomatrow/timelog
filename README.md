# timelog
A time sheet that leverages ledger.

### Usage:
`timelog --in --project='general:specific' --note='Starting for a time'`  
`timelog --out --project='general:specific' --note='Stopping for a time'`  
`timelog -b -- -p 'since today`

### Commands:

h/help    - show this help  
b/balance - show balance for the day, month, or year  
l/list    - list all projects  
e/edit    - edit in terminal editor  
v/visual  - edit in visual editor  
c/cat     - cat timelog file  
f/file    - show timelog file name  
a/active  - show active project  
r/recent  - show most recently closed project  
i/in      - clock into project or last project  
o/out     - clock out of project  
p/project - specify project for clocking  
n/note    - add note to clocking  

### Acknowledgments:
Used `sed`/`awk` expresions from [`t`](https://github.com/nuex/t) by nuex

### Installation:

Clone and move `timelog.fish` into your fish function directory at `~/.config/fish/functions/`.

For completions, add `completions.fish` with the name `timelog.fish` to `.config/fish/completions`
