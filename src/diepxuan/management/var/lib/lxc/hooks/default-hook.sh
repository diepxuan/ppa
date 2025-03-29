#!/usr/bin/env bash
#!/bin/bash

_GLOBAL_EXEC=d_

Yellow='\033[0;33m'
Green='\033[0;32m'
NC='\033[0m'

TXTtrue=[${Green}✓$NC]
TXTinfo=[${Yellow}i$NC]

d_post-create() {
    echo -e "${TXTinfo} Cài đặt ứng dụng trên CT $2..."
    pct exec "$2" -- bash -c "apt update && apt install -y curl"
    pct exec "$2" -- bash -c "curl -s https://ppa.diepxuan.com/install.sh | bash"
    pct exec "$2" -- bash -c "apt install -y ductn"
    echo -e "${TXTtrue} Hoàn thành cài đặt ứng dụng!"
}

[[ (! -x "$_GLOBAL_EXEC$1") && (! $(type -t "$_GLOBAL_EXEC$1") == function) ]] && exit 0

"$_GLOBAL_EXEC$@"
exit 0
