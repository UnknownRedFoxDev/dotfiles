#!/bin/env bash

if command -v tatr &>/dev/null ; then
    output=$(tatr ls 2>/dev/null)
    count=$(echo "$output" | wc -l)
    if (( $count-1 > 0 )); then
        echo "There is a total of $count task(s) open:"
        printf "   %-17s    %-23s    %-20s\n" "Creation date" "Priority" "Task Title"
        while IFS= read -r line; do
            date=$(echo "$line" | awk -F'/' '{printf "%s", $3}')
            priority=$(echo "$line" | sed -e 's/.*\[.*: \(.*\) ,.*/\1/')
            title=$(echo "$line" | sed -e 's/.*\] \(.*\)/\1/')
            printf "  %-24s " "$date"
            printf '%3d' "$(($priority))" 2>/dev/null
            printf "%-14s %s\n" " " "$title"
        done <<< "$output"
        echo -e "\n-------------------------------------------------------------\n"
    fi
fi

