# shimmy container image

Multi-platform container images for [Shimmy](https://github.com/Michael-A-Kuykendall/shimmy), automatically built from upstream release tags.

Images are published to:

- `docker.io/czyt/shimmy`
- `ghcr.io/dockers-x/shimmy`

## Run

```bash
docker run --rm \
  -p 11434:11434 \
  -v "$PWD/models:/app/models" \
  ghcr.io/dockers-x/shimmy:latest
```

The image starts `shimmy serve`, listens on `0.0.0.0:11434`, and reads models from `/app/models`.

## Environment variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `SHIMMY_HOST` | `0.0.0.0` | Listen address |
| `SHIMMY_PORT` | `11434` | HTTP port |
| `SHIMMY_BASE_GGUF` | `/app/models` | Model file or model directory |
| `SHIMMY_KV_QUANT` | unset (`f32`) | Set to `int4` to reduce KV-cache VRAM use |
| `SHIMMY_PREFILL_CHUNK` | unset (`64`) | Reduce to `8` or `16` if long prompts cause GPU timeouts |
| `SHIMMY_MAX_CTX` | unset (model default) | Override the maximum context length |
| `SHIMMY_LOG_LEVEL` | unset | Logging level, for example `debug` |

Additional Shimmy options can be passed after the image name. See the [upstream Chinese documentation](https://github.com/Michael-A-Kuykendall/shimmy/blob/main/docs/zh-CN/README.md).

## Release automation

GitHub Actions checks the latest upstream release every six hours. A missing version is built for `linux/amd64` and `linux/arm64`, published with `latest`, full-version, major/minor, and major tags, and recorded as a matching tag in this repository. The workflow can also be run manually with a specific upstream tag.
