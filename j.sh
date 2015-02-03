#!/bin/zsh
##############################################################
# @title    JScript                                          #
# @author   Filippo Ghibellini                               #
# @desc     intelligent file-tree jumping inspired by z.sh   #
# @version  0.0.1                                            #
##############################################################

# TODO
# - remove older than or more than N records
# - smart name guessing
# - include parents of folders in records ( with lower weight )

# include guard {{{
[[ ! -z $GSCRIPT_INCLUDED ]] && return 0;
GSCRIPT_INCLUDED=true
#}}}

# user-called function {{{
j () {

    [[ $# -eq 0 ]] && \echo "No arguments!" && return 1;

    gfile=~/.j
    dest=$@[-1]
    verbose=true

    scores=$(getscores "$gfile")
    matches=$(echo -n "$scores" | sed -rn "/^$dest:/ p")

    [[ -z "$matches" ]]  && echo "No matches found" && return 1;

    if [[ $# -eq 1 ]]; then
        # simple e.g. 'g projectName'
        first="${matches#*:}"
        first="${first%%:*}"
        $verbose && echo "simple to \"$first\""
        cd "$first"
        return 0
    else
        # call with params e.g. 'g projectName src'
        words=$@[1,-2]
        opts=$(echo -n "${matches#*:}" | tr : '\n')
        topscore=0

        echo -n "$opts" | while read -r option; do
            score=0
            for sword in $words; do
                echo -n "$option" | grep -q "$sword" && let score+=1
            done
            if [[ $score -gt $topscore ]]; then
                top=$option
                topscore=$score
            fi
        done

        if [[ $topscore -eq 0 ]]; then
            echo "Invalid clues!" >&2
            return 1
        else
            $verbose && echo "wordmatching to \"$top\""
            cd "$top"
            return 0
        fi
    fi

}
#}}}

# cd function {{{
# can invoked without parameters to clearout the old records
jcd () {

    # load stats
    gfile=~/.j
    stats=$(getstats "$gfile")

    # insert new record
    [[ $# -gt 0 ]] && newrec="$1" || newrec="$PWD"
    [[ ! -z "$newrec" ]] && stats+="\n$(date "+%s"):$newrec"

    echo "$STAT_HEADER" >!$gfile
    echo "--SCORES" >>$gfile

    # filter out the old records
    oldest=$(date --date '-20 day' +%s)
    stats=$(echo -n "$stats" | gawk -F: '$1>'$oldest)

    # gen new scores
    in=$(echo -n "$stats" | cut -d: -f2)
    echo -n "$in" | gawk -F/ '
    { scores[$NF][$0]++ }
    END {
        for (dir_name in scores) {
            PROCINFO["sorted_in"]="@val_num_desc"
            printf dir_name ":"
            for (option in scores[dir_name])
                printf option ":"
            printf "\n"
        }
    }' >>$gfile

    echo -e "\n--STATS\n$stats" >>$gfile

}

chpwd_functions=( $chpwd_functions jcd )
#}}}

# getscores {{{
getscores() {
    sed -r '/^(#|\s*$)/d' "$1" | sed -rn '/^--SCORES$/,/^--STATS$/ p'
}
#}}}

# getstats {{{
getstats() {
    sed -r '/^(#|\s*$)/d' "$1" | sed -rn '/^--STATS$/,$ p'
}
#}}}

# VARS {{{
STAT_HEADER='###################################################
# JScript stat file                               #
# version: 0.0.1                                  #
#                                                 #
# empty lines & lines starting with # are ignored #
# words prepended with -- delimit sections        #
#                                                 #
###################################################
'
#}}}

# vim: foldmethod=marker :
