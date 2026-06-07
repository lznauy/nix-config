# 密钥管理

## 新机器恢复

```bash
git clone <repo> && cd <repo>
mkdir -p ~/.config/sops/age
nix-shell -p age --run "age -d secrets/age-key.age > ~/.config/sops/age/keys.txt"
chmod 600 ~/.config/sops/age/keys.txt
nh os switch .#physical
```

构建时 sops-nix 用私钥解密 `secrets/secrets.yaml` 到 `/run/secrets/`，通过 `sops.templates` 渲染到目标配置文件。

## 日常操作

### 编辑密钥

```bash
sops secrets/secrets.yaml
```

编辑器里直接修改 value，保存时自动加密。改完后 build 生效：

```bash
nh os switch .#physical
```

### `.sops.yaml` 配置

sops 的配置文件，告诉 `sops` CLI 用哪个 key 加密：

```yaml
keys:
  - &lznauy age12x9w2t9tr3uswn4wzefcg6lzf8fm57t8r4aty0xy0egtlk5yyyzsmpdr7x  # key 别名
creation_rules:
  - path_regex: secrets/secrets\.yaml$  # 匹配文件路径
    age: *lznauy                        # 用哪个 key 加密
```

运行 `sops secrets/secrets.yaml` 时，sops 根据 `path_regex` 找到对应的 key 来加密。

### 添加新密钥

1. `sops secrets/secrets.yaml` 打开编辑器，添加新字段
2. 在 `hosts/common/secrets/api-keys.nix` 中声明 `sops.secrets."字段名"`
3. 在对应的模板文件中使用 `config.sops.placeholder."字段名"`
4. `nh os switch .#physical` 生效

### 添加新工具配置

在 `hosts/common/secrets/` 下创建新 `.nix` 文件，在 `default.nix` 中 import：

```nix
# hosts/common/secrets/new-tool.nix
{ config, ... }:
{
  sops.templates."new-tool.json" = {
    owner = "lznauy";
    group = "users";
    path = "/home/lznauy/.config/new-tool/config.json";
    content = builtins.toJSON {
      apiKey = config.sops.placeholder."api_keys/new-provider";
    };
  };
}
```

然后在 `default.nix` 中添加 `./new-tool.nix`。

## 加密文件清单

| 文件 | 用途 |
|------|------|
| `secrets/age-key.age` | age 私钥备份（密码保护） |
| `secrets/secrets.yaml` | 所有 API key（sops 加密） |
| `.sops.yaml` | sops 配置（指定加密 key） |

## 模块结构

```
hosts/common/secrets/
├── default.nix      ← 汇总 import
├── api-keys.nix     ← 声明 sops secrets
├── omp.nix          ← omp models.yml 模板
├── opencode.nix     ← opencode config 模板
└── claude.nix       ← claude settings 模板
```

## 安全

- `~/.config/sops/age/keys.txt` 私钥 **绝不** 提交 git
- `secrets/age-key.age` 有密码保护，可安全提交
- `secrets/secrets.yaml` 只有 value 加密，key 明文
- 私钥泄露时立即轮换 API Key 并重新生成密钥对
