#! /usr/bin/env bash
# Shell functions, split out of .bashrc.  Sourced by .bashrc for interactive
# shells.  Aliases live in .bash_aliases.

echo "Starting in $(basename "${BASH_SOURCE[0]}")"

# --- OS-specific helpers ------------------------------------------------------
# lshelper backs the ls/la/ll... aliases; o opens a file/dir in the GUI.
if [[ $(uname) == Darwin ]]; then
    function lshelper () {
        CLICOLOR_FORCE=1 /bin/ls -CFG "${@:1:1}" "${@:2}" | less -ERXF
    }
    function o () { open "${*:-.}" ; }
elif [[ $(uname) == Linux ]]; then
    function lshelper () {
        /bin/ls -CF --color=always "${@:1:1}" "${@:2}" | less -ERXF
    }
    function o () { xdg-open "${*:-.}" ; }
fi

# --- navigation ---------------------------------------------------------------
# auto-activate a ./venv when entering a directory that has one
function ifvenv () {
    if [ -e venv ]
    then
        echo "---- Virtual environment found, activating ----"
        source venv/bin/activate
    fi
}

function cd () {
    builtin cd "$*"
    ifvenv
    lshelper .
}
function pd () {
    if [[ $# == 0 ]]
    then
        popd || return
    else
        pushd "$*"
        ifvenv
    fi
}

# --- git ----------------------------------------------------------------------
function gitadddirectory () {
    git rm --cached "$*"
    rm -rf "$*/.git"
    git add "$*"
    git commit -am "Adding $*"
    git push
}

function addcom () {
    for i in "$@"
    do
        echo "$i"
        git add "$i" && git commit -m 'initial' "$i"
    done
}

function git_delete_branch () {
    git branch -d "$1" && git push origin --delete "$1"
}

# --- text / case --------------------------------------------------------------
function tolower () { echo "$*" | tr '[:upper:]' '[:lower:]'; }
function toupper () { echo "$*" | tr '[:lower:]' '[:upper:]'; }
function best () { agrep -B "$@" /usr/share/dict/words; }

function shuf () {
    sort -R "$@" | head -n 1
}

# --- search -------------------------------------------------------------------
function deepgrep ()  { find . -type f -not -name '*\.svn*' -not -name '*,v' -exec grep -I "$*" '{}' ';' -print; }
function deepgrepi () { find . -type f -not -name '*\.svn*' -not -name '*,v' -exec grep -i -I "$*" '{}' ';' -print; }
function docxgrep () {
    for i in "${@:2}"
    do
        if unzip -p "$i" | sed -e 's/<[^>]\{1,\}>//g; s/[^[:print:]]\{1,\}//g' | grep "$1" > /dev/null
        then
            echo "$i"
        fi
    done
}

# --- files / archives ---------------------------------------------------------
function unzipper () {
    for i in "$@"
    do
        unzip "$i"
        rm "$i"
        touch "$i"
    done
}

function rmemptydir () { find "$*" -depth -type d -empty -print -a -exec rmdir '{}' ';' ; }

function zip () { command zip -r "$1".zip "$1" -x '*.git*'; }

# --- conversions --------------------------------------------------------------
function doc2pdf () {
    IFS=
    for i in "$@"
    do
        echo "$i"
        /Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to pdf "$i"
    done
}

# ## front, %% end
function m4a2mp3 () {
    for i in "$@"
    do
        ffmpeg -i "$i" "${i%%.m4a}.mp3"
    done
}

function md { showdown makehtml -i "$1" -o "${1%%.md}".html -c tables; }

# --- image info ---------------------------------------------------------------
function gifinfo () { giftopnm -verbose "$@" > /dev/null; }
function jpginfo () { djpeg -fast -gif "$@" | giftopnm -verbose > /dev/null; }

# --- timers (bell when done) --------------------------------------------------
function timer   { (sleep $((60 * $*)); echo -ne \\a\\a\\a\\a) & }
function minutes { (sleep $((60 * $*)); echo -ne \\a\\a\\a\\a) & }
function seconds { (sleep "$@"; echo -ne \\a\\a\\a\\a) & }

# --- misc ---------------------------------------------------------------------
function sc () {
    /Users/stevebeaty/src/schemacrawler-16.10.1-distribution/_schemacrawler/schemacrawler.sh --no-info --command=schema --database="$1" --info-level=standard --server=sqlite --output-format=png --output-file=schema.png
}

echo "Done with $(basename "${BASH_SOURCE[0]}")"

# vim: wm=0
