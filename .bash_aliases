#! /usr/bin/env bash
# Aliases, split out of .bashrc.  Sourced by .bashrc for interactive shells.
# Functions live in .bash_functions.

# --- listing (ls wrappers call the lshelper function in .bash_functions) ---
alias ls='lshelper'
alias la='lshelper -a'
alias ll='lshelper -l'
alias lla='lshelper -al'
alias lr='lshelper -R'
alias llr='lshelper -lR'
alias lt='lshelper -t'
alias llt='lshelper -lt'

# --- misc ---
alias fixff='cd ~/Library/Application\ Support/Firefox/Profiles/*.default-esr/sessionstore-backups && cp previous.jsonlz4 ../sessionstore.jsonlz4'
alias shrug='echo ¯\\\_\(ツ\)_/¯'
alias listening='netstat -anp tcp | grep "LISTEN"'
alias potm='wget -q -O - http://www.moongiant.com/phase/today/ | grep "Moon Age" | sed -e "s/.*\"Moon Age:/Moon Age:/" -e "s/\".*//"'
alias green="find . -name '*.gif' -exec dirname '{}' ';' | uniq | xargs ~/bin/finder_colors.py green"

# --- removal helpers ---
alias rmnonimage='rm $(file * | grep -v image | sed -e "s/:.*//")'
alias rmhtml='rm $(file * | grep HTML | sed -e "s/:.*//")'
alias rmthumbs="find . -name '*._img*' -print -exec rm '{}' ';'"

# --- git ---
alias git-color='git -c color.ui=always'
alias pr='git checkout -b drb80 && git commit app db test config public -m "drb80" && gh pr create'
alias branch='git branch'
alias co='git checkout'
alias commit='git commit'
alias merge='git merge'
alias pull='git pull'
alias push='git push'
alias status='git status'
alias git_push_this_branch='git push origin $(git branch --show-current)'

# --- maven ---
alias mvncd='cd ../../../../../../..'
alias mvn='mvn -q'

# --- docker ---
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dstopall='docker stop $(docker ps -aq)'
alias drmall='docker stop $(docker ps -aq) && docker rm $(docker ps -aq)'
alias drmiall='docker rmi -f $(docker images -q)'
alias drmvall='docker volume rm $(docker volume ls -q)'

# --- rails ---
alias rrmyseeds='bundle install && yarn install --check-files && rails db:migrate && \cp -f ~/seeds.rb db && rails db:seed && rails server'
alias rrseedless='bundle install && yarn install --check-files && rails db:migrate && rails db:seed && rails server'
alias cleanrails='find . -depth -name node_modules -o -name cache -exec rm -rf "{}" ";"'
alias railspull='git pull git@github.com:msu-denver-cs/${PWD##*/}.git'
alias killspring='ps ax | grep spring | colrm 8 | xargs kill'

# --- languages / tools ---
alias p='python3'
alias venv='python3 -m venv venv'
alias ut='python3 -m unittest'
alias be='bundle exec'
alias beep='echo -n ""'
alias ch='choice'
alias prsst='python3 "${HOME}"/src/PRSST/prsst/main.py &'

# --- system ---
alias unquarantine='xattr -dr com.apple.quarantine'
alias ntpstat='ntpdc -c peers'
alias randompass='openssl rand -base64 12'
alias ramdisk='mkdir /tmp/ramdisk && chmod 777 /tmp/ramdisk && sudo mount -t tmpfs -o size=1G myramdisk /tmp/ramdisk'
alias stealth='sudo ifconfig en0 lladdr 00:11:22:33:44:55'
alias unstealth='sudo ifconfig en1 lladdr a4:5e:60:e8:b9:05'
alias rss='ps aux | sort -n -k 4'

# --- time / dates ---
alias utime='date -r'
alias epoch='date -r'
alias now='date "+%Y%m%d%H%M%S"'
alias today='date "+%Y-%m-%d"'
alias gmt='zdump gmt'
alias phil='zdump Asia/Manila'
alias it='zdump Europe/Rome'

# --- short, everyday shortcuts ---
alias c='clear'
alias cp='cp -i'
alias mv='mv -i'
alias gv='ghostview -magstep -4'
alias h='history'
alias j='jobs'
alias m='less -ReF'
alias more='less -ReF'
alias t='tail'

# vim: wm=0
