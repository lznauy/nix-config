# Agenix 密钥管理

## 新机器恢复

```bash
git clone <repo> && cd <repo>
mkdir -p ~/.config/sops/age
nix-shell -p age --run "age -d secrets/age-key.age > ~/.config/sops/age/keys.txt"
chmod 600 ~/.config/sops/age/keys.txt
sudo nixos-rebuild switch --flake .
```

构建时 agenix 用私钥解密 age 文件到 `/run/agenix/`，再通过 `xdg.configFile` + `mkOutOfStoreSymlink` 链接到 `~/.config/` 下。

## 日常操作

### 编辑加密文件

```bash
nix run github:ryantm/agenix -- -e secrets/<file>.age
```

### 添加新加密文件

1. 明文文件放仓库根目录
2. 加密：`nix-shell -p age --run "age -r age12x9w2t9tr3uswn4wzefcg6lzf8fm57t8r4aty0xy0egtlk5yyyzsmpdr7x -o secrets/<file>.age <file>"`
3. 在 `secrets/secrets.nix` 声明公钥
4. 在 `hosts/default/secrets.nix` 添加 `age.secrets` 条目
5. 在 `home/base/secrets.nix` 用 `xdg.configFile` + `mkOutOfStoreSymlink` 引用
6. 明文文件加入 `.gitignore`

## 加密文件清单

| 文件 | 用途 |
|------|------|
| `secrets/age-key.age` | age 私钥备份（密码保护） |
| `secrets/opencode.json.age` | opencode 配置 |
| `secrets/claude-settings-deepseek.json.age` | Claude Code DeepSeek 配置 |
| `secrets/claude-settings-mimo.json.age` | Claude Code MIMO 配置 |

## 安全

- `~/.config/sops/age/keys.txt` 私钥 **绝不** 提交 git
- `secrets/age-key.age` 有密码保护，可安全提交
- 私钥泄露时立即轮换 API Key 并重新生成密钥对
