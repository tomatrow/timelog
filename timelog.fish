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

    # send output to terminal and the logfile
    function send_log -S
        echo "$argv"
        echo "$argv" >> "$logfile"
    end

    # output to twitter
    function tweet -S -a words
        eval "$tweet_sh post '$words'" > /dev/null; or return 99
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
        switch  - move to a new project instantly
        in      - clock into project or last project
        out     - clock out of project
        project - specify project for clocking
        note    - add note to clocking

        ### Acknowledgments
        Used `sed`/`awk` expresions from [`t`](https://github.com/nuex/t) by nuex\
        """
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
            if test "$punch" = 'o'
                set -l active (show_active)
                if test '' = "$active"
                    return 55 # we are not clocked in
                end
                echo "$active"
            else
                # string match -q -r '\w*' (show_active); and return 77 # return if it's just whitespace
                show_recent
            end | read project
            test -z "$project"; and return 66 # no last project
        end

        if test -n "$note"
            set tailing "  // $note"
            if test "$punch" = 'i'
                echo 'into'
            else
                echo 'out of'
            end | read verb; and tweet "Clocking $verb $project\n$note"
        end

        # The two spaces between project and tailing are required
        echo "$punch $timestamp $project$tailing"
    end

    ##### The Main Portion

    # the main commands are exclusive, then we make sure p/n are only called with i/o/s
    argparse --exclusive 'h,l,e,v,c,f,a,r,b,s,i,o' --exclusive 'h,l,e,v,c,f,a,r,b,p' --exclusive 'h,l,e,v,c,f,a,r,b,n' --name='timelog'\
    'h/help'\
    'l/list'\
    'e/edit'\
    'v/visual'\
    'c/cat'\
    'f/file'\
    'a/active'\
    'r/recent'\
    'b/balance'\
    's/switch' \
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

    if not set -q TIMELOG_TWEET_SH
        echo "Need tweet.sh location set as 'TIMELOG_TWEET_SH'" > /dev/stderr
        return 111
    else
        set tweet_sh "$TIMELOG_TWEET_SH"
    end

    if exists 'help'
        show_help
    else if exists 'list'
        call accounts
    else if exists 'edit'
        eval "$EDITOR $logfile"
    else if exists 'visual'
        eval "$VISUAL $logfile"
    else if exists 'cat'
        cat "$logfile"
    else if exists 'file'
        show_file
    else if exists 'active'
        show_active
    else if exists 'recent'
        show_recent
    else if exists 'balance'
        call balance $argv
    else if exists 'switch'
        set -l active (show_active)
        if test '' = "$active"
            return 55 # we are not clocked in
        end
        clock 'o' '' '' | read -l outlog; or return 66
        clock 'i' "$_flag_project" "$_flag_note" | read -l inlog; or return 77
        send_log "$outlog"
        send_log "$inlog"
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
        clock "$punch" "$_flag_project" "$_flag_note" | read -l transaction
        or return $status

        send_log "$transaction"
    end
end
