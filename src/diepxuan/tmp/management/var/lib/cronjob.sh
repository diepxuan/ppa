#!/usr/bin/env bash
#!/bin/bash

--cron:cronjob:min() {
    --sys:service:valid
}

--cron:cronjob:5min() {
    # --cloudflare:sync
    return 0
}

--cron:cronjob:hour() {
    --sys:service:valid
    --sys:env:sync
}

--cron:cronjob:month() {
    return 0
}

_cron:cronjob:5seconds() {
    _sys:env:send
    _vm:send
}
