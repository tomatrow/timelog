# Author: AJ (tomatrow) Caldwell
# https://tomatrow.github.io

function timelog -d 'Logs time in a ledger readable format.'

    ##### Internal Functions

    # extract the project from an entry
    function extract_project
        awk '''
            $1 != "o" {
                 line = $4
                 for (i=5; i<=NF; i++) {
                    if ($i == "//")
                        break;
                    line = line " " $i;
                 }
                 print line
             }
         '''
    end

    # tests to see if a flag is defined
    function exists -S -a flag_name
        set flag "_flag_$flag_name"
        set -q "$flag"
    end

    # makes a call to ledger with some default parameters
    function call -S
        ledger -f "$logfile" $argv
    end

    ##### Commands

    # Shows some helpful hints
    function show_help
        echo -n \
        """\
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
        recent  - show most recently closed project
        in      - clock into project or last project
        out     - clock out of project
        project - specify project for clocking
        note    - add note to clocking

        Used code from [`t`](https://github.com/nuex/t) by nuex\
        """
    end

    function show_balance -S
        call balance "$argv"
    end

    function show_list -S
        call accounts
    end

    function edit_timelog -S
        eval "$EDITOR $logfile"
    end

    function visual_timelog -S
        eval "$VISUAL $logfile"
    end

    function cat_timelog -S
        cat "$logfile"
    end

    function show_file -S
        echo "$logfile"
    end

    function show_active -S
        sed -e '/^i/!d;$!d' (show_file) | extract_project
    end

    function show_recent -S
         sed -ne '/^o/{g;p;};h;' (show_file) | tail -n 1 | extract_project
    end

    # Covers --in, --out, --project, and --note
    function clock -S -a punch project note

        test "$punch" = 'i' -o "$punch" = 'o'; or return 33
        set -l timestamp (date '+%Y/%m/%d %H:%M:%S')

        # Assign default projects
        if test -z "$project"
            switch "$punch"
            case 'o'
                show_active
            case 'i'
                # string match -q -r '\w*' (show_active); and return 77 # return if it's just whitespace
                show_recent # # no active project, bad
            end | read project
            test -z "$project"; and return 66 # no last project
        end

        if test -n "$note"
            set tailing "  // $note"
        end

        # The two spaces between project and tailing are required
        echo "$punch $timestamp $project$tailing"
    end

    ##### The Main Portion

    argparse --exclusive 'h,b,l,e,v,i,o,a,r' --name='timelog'\
    'h/help'\
    'l/list'\
    'e/edit'\
    'v/visual'\
    'c/cat'\
    'f/file'\
    'a/active'\
    'r/recent'\
    'b/balance=?'\
    'i/in'\
    'o/out'\
    'p/project='\
    'n/note='\
    -- $argv
    or return 22

    # set the timelog file location
    if set -q 'TIMELOG_FILE'
        echo "$TIMELOG_FILE"
    else
        echo "$HOME/.journal.timeclock"
    end | read logfile

    if exists 'help'
        show_help
    else if exists 'list'
        show_list
    else if exists 'edit'
        edit_timelog
    else if exists 'visual'
        visual_timelog
    else if exists 'cat'
        cat_timelog
    else if exists 'file'
        show_file
    else if exists 'active'
        show_active
    else if exists 'recent'
        show_recent
    else if exists 'balance'
        show_balance $argv
    else
        # we are clocking in|out
        if exists 'in'
            echo 'i'
        else if exists 'out'
            echo 'o'
        else
            return 44
        end | read punch

        # Construct ledger line
        clock "$punch" "$_flag_project" "$_flag_note" | read -l output
        or return $status

        # Send outputs
        echo "$output" >> "$logfile"
        echo "$output"
    end
end
