# Pi-Hole image with builtin ssh daemon gravity sync and tailscale

## Docker image
Docker image is built in multi-arch mode.
Following hosts are supported:
 - `amd64`
 - `arm64` (aka `aarch64`)
 - `armv7` (aka `armhf`)
## SSHD

### Environment variables
 - `SSHD_ENABLE` - default `false`. Enabled SSH daemon
 - `SSH_PORT` - default `2223`. If container is running in host mode port 22 may already be bound.
 - `SSH_KEY` - public key from remote gravity sync instance
 - `SSH_KEY_TYPES` - default `ssh-ed25519,rsa-sha2-512,rsa-sha2-256,ssh-rsa`
 
## Gravity Sync
Gravity Sync requires [SSHD](#sshd) to be configured and on.
### Environment variables
 - `GS_ENABLE` - default `false`. Enable Gravity Sync
 - `GS_MODE` - default `smart`
 - `GS_SYNC_PERIOD` - default `*/5 * * * *`
 - `GS_ETC_PATH` - default `/etc/gravity-sync`
 - `GS_CONFIG_FILE` - default `gravity-sync.conf`
 - `GS_SSH_PORT` - default `22`
 - `GS_REMOTE_HOST` - remove Gravity Sync instance. Must be set
 
## Tailscale

### Environment variables
 - `TAILSCALE_ENABLE` - default `false`. Enable tailscale daemon
 - `TAILSCALE_ARGS` - extra arguments to the `tailscale`
 - `TAILSCALE_ACCEPT_DNS` - default `false`
 - `TAILSCALE_AUTHKEY` - optional. You may pass API key obtained from tailscale account. Otherwise, it falls to default auth mechanism.
 - `TAILSCALED_ARGS` - extra arguments to the `tailscaled`. For example `TAILSCALED_ARGS=--tun=tailscaled1`

## Examples

Plain pihole
```shell
docker run --name pihole \
    ghcr.io/troian/pihole:latest
```

Pihole with gravity sync in smart mode (default)
```shell
docker run --name pihole \
    -e SSHD_ENABLE=true \
    -e SSH_PORT=2223 \
    -e SSH_KEY=<your-pub-key> \
    -e GS_ENABLE=true \
    -e GS_REMOTE_HOST=<ip address> \
    ghcr.io/troian/pihole:latest
```

Pihole with Tailscale
```shell
docker run --name pihole \
    -e TAILSCALE_ENABLE=true \
    ghcr.io/troian/pihole:latest
```
