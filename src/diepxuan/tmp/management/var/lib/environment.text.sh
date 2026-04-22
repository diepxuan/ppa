#!/usr/bin/env bash
#!/bin/bash

TXTtrue=[${Green}✓$NC]
TXTfalse=[${Red}✗$NC]
TXTinfo=[${Yellow}i$NC]

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
