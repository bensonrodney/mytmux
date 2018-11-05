#!/bin/bash                                                                                  

# session name
SESS="mytmux"
FIRST_WINDOW=""

# NOTE: a horizontal split gives you side-by-side panes (vertical panes)
#       a vertical split gives you above/below panes (horizontal panes)

function usage(){
    cat <<EOFUSAGE
Sets up the tmux session that I use all the time if it isn't already setup,
otherwise the script just connects to the session.

If the -k option is used the session and all its panes are closed down.

Usage:
    ${0} [-k]

    where -k: kill the whole session so that you don't have to go and
              close every pane.

EOFUSAGE
}

function kill_session(){
    tmux kill-session -t $SESS
}

function new_window(){
    # only creates a new window if we're not at the first window (window 0)
    winname=$1
    if [[ -z ${FIRST_WINDOW} ]] ; then
        FIRST_WINDOW="true"
        tmux new-session -s $SESS -n ${winname} -d
    else
        tmux new-window -n "${winname}"
    fi
}

function open_repo(){
    # opens a git repo in two side-by-side panes
    winname=$1
    repopath=$2
    new_window "${winname}"
    # note: 'git l' is an alias in my .gitconfig file
    tmux send-keys "cd ${repopath}" C-m "git l" C-m "q"
    tmux split-window -h -t 0
    tmux send-keys "cd ${repopath}" C-m
}

function triple_window(){
    # two panes above a full width one
    winname=$1
    new_window "${winname}"
    tmux split-window -v -t 0
    tmux split-window -h -t 0
    tmux select-pane -t 0
}

function triple_above_htop() {
    # creates 3 evenly spaced panes above htop in a full width pane
    winname=$1
    new_window "${winname}"
    tmux split-window -v -t 0 
    tmux send-keys -t $SESS "htop" C-m 
    tmux select-pane -t 0
    tmux split-window -p 33 -h -t 0
    tmux select-pane -t 0
    tmux split-window -p 50 -h -t 0
    tmux select-pane -t 0
}

function setup_session(){
    # put your setup code here, you can call existing functions,
    # create your own functions and/or put window specific code here
    triple_above_htop htop

    open_repo myrepo /path/to/repo

    triple_window triple

    tmux select-window -t 0
}

while getopts "kh" o; do
    case "${o}" in
        k)
            kill_session
            exit 0
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: ${o}"
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))


if ! tmux has-session -t $SESS &> /dev/null ; then
    setup_session
fi

tmux attach -t $SESS

