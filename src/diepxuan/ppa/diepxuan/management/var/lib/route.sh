#!/usr/bin/env bash
#!/bin/bash

--route:default() {
    ip r | grep ^default | head -n 1 | grep -oP '(?<=dev )[^ ]*'
}
