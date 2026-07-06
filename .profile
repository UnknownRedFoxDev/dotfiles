#!/bin/env bash

if command -v quickshell; then
    if [[ -f $HOME/opt/skwd-wall/daemon.qml ]] then;
        quickshell -p $HOME/opt/skwd-wall/daemon.qml &>/dev/null &
    fi
fi
