#!/usr/bin/env bash

echo "127.0.0.1 ${VIRTUAL_HOST:-pi.hole}" >> /etc/hosts
