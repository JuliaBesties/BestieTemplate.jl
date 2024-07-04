#!/bin/bash

declare repo=$1

while IFS= read -r -d '' f; do
    f=${f/src/build}; # <repo>/docs/src/<path> -> <repo>/docs/build/<path>
    case $f in
        *index.md)		# <path>/index.md -> <path>/index.html
	    f=${f/%.md/.html};;
        *)			# <path>/<rest>.md -> <path>/<rest>/index.html
	    f=${f/%.md//index.html};;
    esac
    [[ ! -e $f ]] && { echo "$f" missing; }
done < <(find "$repo/docs/" -type f -name '*.md' -print0 ) | grep missing
[[ $? -ne 0 ]]
