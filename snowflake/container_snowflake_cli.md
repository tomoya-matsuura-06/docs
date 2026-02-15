##### Snowflake CLI をコンテナ化して時間短縮する

```docker
FROM python:3.10-slim-bookworm

RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install snowflake-cli-labs==3.12.0

RUN git config --global --add safe.directory '*'

ENTRYPOINT ["/bin/bash"]
```

##### Point
1. `rm -rf /var/lib/apt/lists/*` にて　DL したパッケージリストを削除して軽量化。
2. `RUN git config --global --add safe.directory '*'` にて所有者エラー回避を宣言

---

##### .yml ファイルにて呼び出す
```yml
name: xxx

on:
  workflow_dispatch:
  push:
    branches:
      - 'xxx'
    paths:
      - 'Dockerfile'

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}/snowflake-cli

jobs:
  build:
    runs-on: lg-ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:3.12.0
```
