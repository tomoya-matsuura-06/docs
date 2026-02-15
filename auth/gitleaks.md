 **Gitleaks 導入手順**
##### 1. インストール
```bash
brew install pre-commit 
```

##### 2. フォルダ作成
```bash
mkdir -p ~/.git-hooks
```
###### ↓ フック用ディレクトリと連携（初期では存在しない、書き換えではない）
```bash
git config --global core.hooksPath ~/.git-hooks
```

##### 3. ファイル作成
```bash
vim ~/.git-hooks/pre-commit-config-global.yml
```
    repos:
        - repo: https://github.com/gitleaks/gitleaks
    rev: v8.30.0
    hooks:
        - id: gitleaks

##### 4. 紐付け
```bash
vim ~/.git-hooks/pre-commit
```
    #!/bin/bash
    pre-commit run --config ~/.git-hooks/pre-commit-config-global.yml


##### 5. 権限付与
```bash
chmod +x ~/.git-hooks/pre-commit
```


---

##### 保守
月に 1 度最新のバージョンを確認し、設定ファイルのバージョンのみ手動書き換え

> *バージョン確認先*
https://github.com/gitleaks/gitleaks/releases
>
