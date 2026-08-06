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

The image build is split across four GitHub Actions jobs, one per supported
platform. The Anki server is compiled inside the Docker build for each job.
The jobs push temporary platform images, and a final job publishes one
multi-architecture manifest for each public tag.

The Anki release tag is stored in [`anki-version`](./anki-version). Automatic
image builds are triggered only when that file changes; use `workflow_dispatch`
to build manually after changing the Docker setup.

To build one platform locally, use Buildx and provide the Anki version:

```sh
docker buildx build \
  --platform linux/amd64 \
  --build-arg ANKI_VERSION="$(cat anki-version)" \
  --tag anki-sync-server:local \
  .
```

You can find this image on [GHCR](https://github.com/f7zorn/anki-sync-server-docker/pkgs/container/anki-sync-server) and for legacy support on [Docker Hub](https://hub.docker.com/r/zorrn/anki-sync-server) and my old [GHCR](https://github.com/orgs/z0rrn/packages/container/package/anki-sync-server) (may change anytime).

Available tags:

- `latest`: Latest version of anki.
- `<anki version>`: Specified version of anki.
- `sha-<git commit hash>`: Git commit hash.

## Setup

This is a basic docker-compose.yml to setup anki.

```yaml
services:
  # https://github.com/f7zorn/anki-sync-server-docker
  anki-sync-server:
    image: ghcr.io/f7zorn/anki-sync-server:25.02
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
