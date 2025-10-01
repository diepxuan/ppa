#!/usr/bin/env bash
#!/bin/bash

--sys:service:main() {
    # trap 'wait' CHLD

    local vm_sync_pid=0
    local route_check_pid=0
    
    local counter=0
    while true; do
        if (( counter % 10 == 0 )) && ! ( [[ $vm_sync_pid -ne 0 ]] && kill -0 "$vm_sync_pid" 2>/dev/null ); then
            d_vm:sync &
            vm_sync_pid=$!
        fi

        if (( counter % 5 == 0 )) && ! ( [[ $route_check_pid -ne 0 ]] && kill -0 "$route_check_pid" 2>/dev/null ); then
            d_route:checkAndUp &
            route_check_pid=$!
        fi

        sleep 1
        # ((counter++))
        (( counter = (counter + 1) % 10 ))
    done

    return 0

    while true; do
        sleep 1
        local second=$(date +%S)
        local minute=$(date +%M)

        # execute every 30mins
        if [[ $second == 0 ]] && [[ $(($minute % 30)) == 0 ]]; then
            :
            # --cron:cronjob:hour
        fi

        # execute every 10mins
        if [[ $second == 0 ]] && [[ $(($minute % 10)) == 0 ]]; then
            :
            # --cron:cronjob:hour
            # d_vm:sync
        fi

        # execute every 5mins at 0 second
        if [[ $second == 0 ]] && [[ $(($minute % 5)) == 0 ]]; then
            :
            # --cron:cronjob:5min
        fi

        # execute every minute at 1 second
        if [[ $second == 1 ]]; then
            :
            # --cron:cronjob:min
            # d_vm:sync
        fi

        # Thực hiện công việc định kỳ mỗi 10 giây
        # ((second % 10 == 0)) && d_vm:sync
        (($(date +%S) % 10 == 0)) && d_vm:sync

        # Thực hiện công việc định kỳ mỗi 5 giây
        # (($(date +%S) % 5 == 0)) && d_vm:sync

        # execute every 10 seconds
        if [[ $(($second % 10)) == 0 ]]; then
            :
            # _cron:cronjob:5seconds
            d_vm:sync
        fi

        # execute every 5 seconds
        if [[ $(expr $(date +%S) % 5) == 0 ]]; then
            :
            # _cron:cronjob:5seconds
            d_vm:sync
        fi
    done

    return 0

    # Đọc và lưu cấu hình từ file
    cron_file="tasks.cron"
    while true; do
        sleep 1

        current_time=$(date "+%S %M")
        current_second=$(echo "$current_time" | cut -d' ' -f1)
        current_minute=$(echo "$current_time" | cut -d' ' -f2)

        # Đọc từng dòng trong file cấu hình
        while IFS= read -r line; do
            # Bỏ qua các dòng trống hoặc dòng bắt đầu bằng #
            [[ -z "$line" || $line =~ ^# ]] && continue

            # Tách cột minute, second và command
            minute=$(echo "$line" | awk '{print $1}')
            second=$(echo "$line" | awk '{print $2}')
            command=$(echo "$line" | awk '{print $3}')

            # Kiểm tra điều kiện theo cột minute
            if [[ "$minute" == "*" || $((current_minute % ${minute//\*/1})) -eq 0 ]]; then
                # Kiểm tra điều kiện theo cột second
                if [[ "$second" == "*" || $((current_second % ${second//\*/1})) -eq 0 ]]; then
                    # Thực thi command
                    eval "$command"
                fi
            fi
        done <"$cron_file"
    done
}

d_run_as_service() {
    [[ "$1" == "--help" ]] &&
        echo "Run package as service" &&
        return
    # _SERVICE_NAME=ductnd
    # if [ ! "$(--sys:service:isactive $_SERVICE_NAME)" == "active" ]; then
    #     sudo systemctl stop ${_SERVICE_NAME//'.service'/}
    #     sudo systemctl start ${_SERVICE_NAME//'.service'/}
    #     return
    # fi
    --sys:service:main
}

--sys:service:isactive() { #SERVICE_NAME
    _SERVICE_NAME=ductnd
    if [[ ! -z ${@+x} ]]; then
        _SERVICE_NAME="$@"
    fi
    IS_ACTIVE=$(sudo systemctl is-active $_SERVICE_NAME)
    echo $IS_ACTIVE
}

--sys:service:restart() { #SERVICE_NAME
    _SERVICE_NAME=ductnd
    if [[ ! -z ${@+x} ]]; then
        _SERVICE_NAME="$@"
    fi
    if [ ! "$(--sys:service:isactive $_SERVICE_NAME)" == "inactive" ]; then
        sudo systemctl stop ${_SERVICE_NAME//'.service'/}
        sudo systemctl restart ${_SERVICE_NAME//'.service'/}
    fi
}

--sys:service:re-install() {
    --sys:service:unistall
    --sys:service:install
}

--sys:service:install() {
    # sudo systemctl daemon-reload
    if [ "$(--sys:service:isactive)" == "failed" ]; then
        --sys:service:unistall
    fi

    if [ "$(--sys:service:isactive)" == "inactive" ] || [ "$(--sys:service:isactive)" == "failed" ]; then
        # restart the service
        #     echo "Service is running"
        #     echo "Restarting service"
        #     sudo systemctl restart ductnd
        #     echo "Service restarted"
        # else

        # create service file
        # echo "Creating service file"
        # echo -e "$_DUCTN_SERVICE" | sudo tee /usr/lib/systemd/system/ductnd.service >/dev/null 2>&1
        # ls -la /usr/lib/systemd/system/ | grep ductn
        # ls -la /etc/systemd/system/ | grep ductn

        # restart daemon, enable and start service
        # echo "Reloading daemon and enabling service"
        sudo systemctl daemon-reload
        sudo systemctl enable ductnd # remove the extension
        sudo systemctl restart ductnd
        # sudo systemctl status ductnd
    # echo "Service Started"
    # echo "aaa" | sudo tee /etc/systemd/system/ductn.service
    fi
}

--sys:service:unistall() {
    sudo systemctl kill ductnd    # remove the extension
    sudo systemctl stop ductnd    # remove the extension
    sudo systemctl disable ductnd # remove the extension
    sudo rm -rf /etc/systemd/system/*ductnd.service
    sudo rm -rf /usr/lib/systemd/system/*ductnd.service
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
