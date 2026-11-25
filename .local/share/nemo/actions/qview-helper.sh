#!/bin/bash
path=$(echo "$1" | sed 's/\\\(.\)/\1/g')
/home/beaty/.local/bin/qview "$path"
