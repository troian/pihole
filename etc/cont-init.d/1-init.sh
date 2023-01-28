#!/usr/bin/env bash

if [[ ${SSHD_ENABLE:=false} == true ]]; then
    mkdir -p /run/sshd
fi

if [[ ${TAILSCALE_ENABLE:=false} == true ]]; then
    mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale
fi
