#!/usr/bin/env bash

if [[ ${SSHD_ENABLE:=false} == true ]]; then
    mkdir -p /run/sshd
fi
