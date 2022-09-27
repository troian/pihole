# Pi-Hole image with builtin ssh daemon

Use `SSH_KEY` environment variable to set public key. For example:
```shell
docker run --name pihole -e SSH_KEY=<your-pub-key> ghcr.io/troian/pihole
```

## Host mode
If container is running host mode port 22 may already be bound if there is host sshd is running.
Use `SSH_PORT` to set custom port. For example

```shell
docker run --name pihole -e SSH_PORT=2223 -e SSH_KEY=<your-pub-key> ghcr.io/troian/pihole
```
