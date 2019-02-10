#! /bin/bash

cd ~
FILES='.vimrc .bash_profile .bashrc bin/choice bin/bash-powerline.sh'
rm -f $FILES
for i in $FILES
do
    echo $i
    ln -s ~/src/dotfiles/$i $i
done
