#!/usr/bin/env bash
#!/bin/bash

--sys:service:valid() {
    --sys:service:httpd
    --sys:service:mysql
    --sys:service:mssql
}

--sys:service:httpd() {
    if [ "$(--sys:service:isactive apache2)" == "failed" ]; then
        --swap:install
        --log:cleanup
        --sys:service:restart apache2
    fi
}

--sys:service:mysql() {
    if [ "$(--sys:service:isactive mysql)" == "failed" ]; then
        --swap:install
        --log:cleanup
        --sys:service:restart mysql
    fi
}

--sys:service:mssql() {
    if [ "$(--sys:service:isactive mssql-server)" == "failed" ]; then
        --swap:install
        --log:cleanup
        --sys:service:restart mssql-server
    fi
}

--sys:service:dhcp() {
    if [ $(--host:is_server) = 1 ] && [ "$(--sys:service:isactive isc-dhcp-server)" == "failed" ]; then
        sudo killall dhcpd
        sudo rm -rf /var/run/dhcpd.pid
        --sys:service:restart isc-dhcp-server
    fi
}
