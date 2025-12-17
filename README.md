# Docker anki-sync-server

Docker image for [Anki Sync Server](https://apps.ankiweb.net/).

> [!CAUTION]
> This image is not official. Use at your own risk.

## Information

This image is available for following architectures:

- linux/amd64
- linux/386
- linux/arm64
- linux/arm/v7

The container and the actions are auto-updated whenever a new version of anki is released. This is done by a GitHub Action and I can forget this project exists :).

You can find this image on [GHCR](https://github.com/z0rrn/anki-sync-server-docker/pkgs/container/anki-sync-server) and on [Docker Hub](https://hub.docker.com/r/zorrn/anki-sync-server).

Available tags:

- `latest`: Latest version of anki.
- `<anki version>`: Specified version of anki.
- `sha-<git commit hash>`: Git commit hash.

## Setup

This is a basic docker-compose.yml to setup anki.

```yaml
services:
  # https://github.com/z0rrn/anki-sync-server-docker
  anki-sync-server:
    image: ghcr.io/z0rrn/anki-sync-server:25.02
    # These are sample passwords, please change them
    environment:
      - SYNC_USER1=panda:rsfPz4NXELBxmJ
      - SYNC_USER2=penguin:2Qtf5nnsDpsQ3b
    volumes:
      - anki-sync-server:/config
    ports:
      - 27701:27701

volumes:
  anki-sync-server:
```

Set SYNC_USERX (more users are possible) to your desired username and password and open port 27701 in your reverse proxy or firewall.

**For more configuration options see <https://docs.ankiweb.net/sync-server.html>**

## Contributing & License

Contributions are welcome. All files are licensed under Apache-2.0.
