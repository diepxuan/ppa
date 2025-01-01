#!/usr/bin/env bash
#!/bin/bash

d_port:open() {
    $SUDO lsof -nP | grep LISTEN
}
