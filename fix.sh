#! /bin/bash
#! /bin/bash -x

# Install model: this repo is checked out with $HOME as its working tree (a
# shallow clone into ~), so .bashrc, bin/*, .config/autostart/* etc. are
# already in place -- there is no linking step.  This script only (a) applies
# desktop/terminal settings and (b) copies the few files that must live
# outside the home tree (browser userChrome.css, Thunderbird msgFilterRules).

# dconf watch /

shopt -s nullglob

# where this repo lives, so we can find files to copy regardless of checkout
# location (~, ~/src/dotfiles, ...).
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Is a gsettings schema installed?  Checks both fixed and relocatable schemas
# (the terminal Profile schema is relocatable and only appears in the latter).
# SCHEMAS is populated once by WMsettings.
function has_schema () {
    local s
    for s in "${SCHEMAS[@]}"; do [[ "$s" == "$1" ]] && return 0; done
    return 1
}

# gsettings set, but only when the schema exists, so each call is a silent
# no-op on a desktop that doesn't ship it (e.g. a labwc-only Raspberry Pi).
# Strips any :/relocatable/path/ suffix before checking.
function gset () {
    has_schema "${1%%:*}" && gsettings set "$@"
}

# X window manager etc. settings (Cinnamon / GNOME Terminal via gsettings)
function WMsettings () {
    command -v gsettings > /dev/null 2>&1 || return 0
    mapfile -t SCHEMAS < <(gsettings list-schemas 2>/dev/null; gsettings list-relocatable-schemas 2>/dev/null)

    # Solarized palette, standard 16-colour order (base/accent colours).
    PALETTE="['#073642', '#dc322f', '#859900', '#b58900', '#268bd2', '#d33682', '#2aa198', '#eee8d5', '#002b36', '#cb4b16', '#586e75', '#657b83', '#839496', '#6c71c4', '#93a1a1', '#fdf6e3']"
    A='org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:'

    # GNOME Terminal profiles: block cursor, Solarized light (base3 bg / base00
    # fg), an 80x44 window.
    if has_schema org.gnome.Terminal.ProfilesList
    then
        UUIDS=$(gsettings get org.gnome.Terminal.ProfilesList list | tr -d "',")
        # kinda 2-d array
        a=(cursor-blink-mode cursor-shape use-theme-colors background-color foreground-color palette default-size-columns default-size-rows)
        b=(off block false '#fdf6e3' '#657b83' "${PALETTE}" 80 44)
        for UUID in ${UUIDS}
        do
            length=${#a[@]}
            for (( i=0; i<length; i++ ))
            do
                gset "${A}${UUID}"/ "${a[$i]}" "${b[$i]}"
            done
        done
    fi

    gset org.gnome.desktop.interface cursor-blink false
    gset org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

    # Caps Lock becomes another Control key.
    gset org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"

    WM=org.cinnamon.desktop.keybindings.wm
    a=( close minimize switch-to-workspace-right switch-to-workspace-left )
    b=( "['<Super>q']" "['<Super>m', '<Super>h']" "['<Super>Right']" "['<Super>Left']" )
    for (( i=0; i<${#a[@]}; i++ ))
    do
        gset "${WM}" "${a[$i]}" "${b[$i]}"
    done

    a=( auto-raise focus-mode )
    b=( "true" "sloppy" )
    WM=org.cinnamon.desktop.wm.preferences
    for (( i=0; i<${#a[@]}; i++ ))
    do
        gset "${WM}" "${a[$i]}" "${b[$i]}"
    done
}

# Raspberry Pi / labwc (Wayland) equivalents of the Cinnamon gsettings above:
#   - rc.xml <focus>:   focus-follows-mouse + raise-on-focus (sloppy/auto-raise)
#   - environment:      Caps Lock becomes another Control key
# No-op unless labwc is installed.  Both files use the FIRST copy labwc finds,
# so we seed each from the system default to keep the distro's settings, then
# patch in place.  Idempotent: re-running does nothing once the values are set.
function LabwcSettings () {
    command -v labwc > /dev/null 2>&1 || return 0

    mkdir -p ~/.config/labwc

    # --- rc.xml: focus-follows-mouse + raise-on-focus -------------------------
    RC=~/.config/labwc/rc.xml
    if [[ ! -e ${RC} ]]
    then
        if [[ -e /etc/xdg/labwc/rc.xml ]]
        then
            cp /etc/xdg/labwc/rc.xml "${RC}"
        else
            printf '<?xml version="1.0"?>\n<labwc_config>\n</labwc_config>\n' > "${RC}"
        fi
    fi

    if grep -q '<followMouse>yes</followMouse>' "${RC}" &&
       grep -q '<raiseOnFocus>yes</raiseOnFocus>' "${RC}"
    then
        echo "labwc focus already set in ${RC}"
    else
        echo "setting labwc focus in ${RC}"

        FOCUS='  <focus>\n'
        FOCUS+='    <followMouse>yes</followMouse>\n'
        FOCUS+='    <followMouseRequiresMovement>no</followMouseRequiresMovement>\n'
        FOCUS+='    <raiseOnFocus>yes</raiseOnFocus>\n'
        FOCUS+='  </focus>'

        # drop any existing (partial or stale) <focus> block, then insert ours
        # just before the closing root tag.
        sed -i -e '/<focus>/,/<\/focus>/d' "${RC}"
        sed -i -e "s|</labwc_config>|${FOCUS}\n</labwc_config>|" "${RC}"
    fi

    # --- environment: Caps Lock -> Control ------------------------------------
    ENV=~/.config/labwc/environment
    if [[ ! -e ${ENV} && -e /etc/xdg/labwc/environment ]]
    then
        cp /etc/xdg/labwc/environment "${ENV}"
    fi
    touch "${ENV}"

    if grep -q '^XKB_DEFAULT_OPTIONS=.*ctrl:nocaps' "${ENV}"
    then
        echo "labwc caps-lock already set in ${ENV}"
    elif grep -q '^XKB_DEFAULT_OPTIONS=' "${ENV}"
    then
        # add to the existing comma-separated option list
        sed -i -E 's/^(XKB_DEFAULT_OPTIONS=.*)$/\1,ctrl:nocaps/' "${ENV}"
        echo "added ctrl:nocaps to XKB_DEFAULT_OPTIONS in ${ENV}"
    else
        echo 'XKB_DEFAULT_OPTIONS=ctrl:nocaps' >> "${ENV}"
        echo "set XKB_DEFAULT_OPTIONS=ctrl:nocaps in ${ENV}"
    fi
}

# macOS equivalents of WMsettings.
function MacSettings () {
    # Caps Lock becomes another Control key.  hidutil applies this for the
    # current login session; to make it survive reboots, install a LaunchAgent
    # that runs this same command at login.
    hidutil property --set \
        '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}' \
        > /dev/null
}

function mozilla_prefs () {
    if [[ $(grep "${1}" "${2}") == "" ]]
    then
        echo 'user_pref("'"${1}"'", "'"${3}"'");' >> "${2}"
    fi
}

function userChrome () {
   for DIR in "${@}"
   do
       echo "${DIR}"

       CHROME="${DIR}"/chrome
       mkdir "${CHROME}" 2> /dev/null

       PREFS=${DIR}/prefs.js
       STYLE='toolkit.legacyUserProfileCustomizations.stylesheets'
       VALUE=true

       STYLE="widget.gtk.overlay-scrollbars.enabled"
       VALUE=false
       mozilla_prefs "${STYLE}" "${PREFS}" "${VALUE}"

       FILE="${CHROME}"/userChrome.css
       if [[ "${DIR}" =~ .*[Tt]hunderbird.* ]]
       then
           cp -f "${DOTFILES}/TBuserChrome.css" "${FILE}"
        else
           cp -f "${DOTFILES}/userChrome.css" "${FILE}"

           STYLE='browser.backspace_action'
           VALUE=2
           mozilla_prefs "${STYLE}" "${PREFS}" "${VALUE}"
        fi
    done
}

function outlook () {
    for DIR in "${@}"
    do
        echo "${DIR}"

        FILE="${DIR}"/msgFilterRules.dat
        cp -f "${DOTFILES}/msgFilterRules.dat" "${FILE}"
    done

}

# sigh, see: https://superuser.com/questions/1507251/firefox-has-two-default-profiles-default-release-and-default-which-one-sho
FF=("${HOME}"/.mozilla/firefox/* "${HOME}"/Library/Application\ Support/Firefox/Profiles/*)
userChrome "${FF[@]}"

TB=("${HOME}"/.thunderbird/* "${HOME}"/Library/Thunderbird/Profiles/*)
userChrome "${TB[@]}"

OL=("${HOME}"/.thunderbird/*.default*/webaccountMail/outlook.office365*.com "${HOME}"/Library/Thunderbird/Profiles/*.default*/webaccountMail/outlook.office365*.com)
outlook "${OL[@]}"

if [[ $(uname) == Linux ]]
then
    WMsettings
    LabwcSettings
elif [[ $(uname) == Darwin ]]
then
    MacSettings
fi

# vim: wm=0
