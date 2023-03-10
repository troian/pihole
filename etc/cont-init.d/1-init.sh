#!/usr/bin/env bash

if [[ ${SSHD_ENABLE:=false} == true ]]; then
    mkdir -p /run/sshd
fi

update_gravity=${PHUL_UPDATE_GRAVITY:-false}

ucfg=${PHUL_CONFIG_FILE:-/etc/pihole-updatelists/pihole-updatelists.conf}

# shellcheck disable=SC1090
source <(sed -E -n 's/^/export PHUL_&/ p' "${ucfg}")

update_gravity=${PHUL_UPDATE_GRAVITY:-${update_gravity}}

if [[ "${update_gravity}" == "true" ]]; then
    # shellcheck disable=SC2016
    sed -i 's/^[^#]*pihole updateGravity/#&/' /etc/cron.d/pihole
fi
