#!/bin/env bash

pactl subscribe | while read -r line; do
    if echo "$line" | grep --quiet "change"; then
        touch /tmp/custom_pulseaudio_event
    fi
done
