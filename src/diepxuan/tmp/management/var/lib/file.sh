#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("file:chmod")
--file:chmod() {
    # sudo stat -c "%a" $1 2>/dev/null
    stat -c "%a" $1 2>/dev/null
}

--file:chmod:files() {
    sudo find $2 -type f -exec sudo chmod $1 {} \;
}

--file:chmod:dirs() {
    sudo find $2 -type d -exec sudo chmod $1 {} \;
}
