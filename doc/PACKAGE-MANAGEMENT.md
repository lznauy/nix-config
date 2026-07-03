# 非 nixpkgs 软件包管理

当需要安装的软件不在 nixpkgs 中时，按以下优先级选择方案。

## 优先级总览

| 优先级 | 方案 | 适用场景 |
|--------|------|----------|
| **A** | flake input | 上游提供 flake |
| **B** | NUR 社区包 | 社区已有人打包 |
| **C** | 源码构建 | 源码可用，需自行打包 |
| **D** | autoPatchelfHook | 预编译 ELF，库版本兼容 |
| **E** | buildFHSEnv | 闭源 / soname 不匹配的兜底 |

## 决策流程

```
上游有 flake？
├─ 是 → A：flake input
└─ 否 → NUR 有现成包？
         ├─ 是 → B：NUR 社区包
         └─ 否 → 有预编译 release？
                  ├─ 是 → ELF 格式？
                  │       ├─ 是 → D：autoPatchelfHook
                  │       └─ 否（AppImage 等）→ E：buildFHSEnv
                  └─ 否 → 有源码？
                          ├─ 是 → C：buildRustPackage / buildGoModule
                          └─ 否 → C：mkDerivation
```

---

## A. flake input（最高优先级）

上游提供了 flake 的情况。只需声明 input，无需自己打包。

```nix
# flake.nix
inputs.某工具 = {
  url = "github:某人/某工具";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

引入方式根据上游暴露的输出类型：

```nix
# 方式 A：overlay
nixpkgs.overlays = [
  (final: prev: { 某工具 = inputs.某工具.packages.${prev.stdenv.hostPlatform.system}.default; })
];

# 方式 B：home-manager module
home-manager.sharedModules = [ inputs.某工具.homeModules.default ];
```

**优点**：上游维护打包，`nix flake update` 即可升级。
**缺点**：依赖上游提供 flake。
**已有案例**：`quien`、`noctalia`、`claude-code`、`nixvim`、`stylix`。

---

## B. NUR 社区包

社区维护的第三方包集合，类似 AUR。如果 NUR 中已有现成包，优先使用，避免重复打包。

### 接入方式

```nix
# flake.nix
inputs.nur.url = "github:nix-community/NUR";
```

```nix
# 在 overlay 中引入
nixpkgs.overlays = [ inputs.nur.overlays.default ];
```

### 使用方式

```nix
# home.packages 中引用
pkgs.nur.repos.<作者>.<包名>
```

### 常用社区源

| 作者 | 内容 | 示例包 |
|------|------|--------|
| **xddxdd** | 中文软件、网络工具、AI/ML、内核模块、桌面应用（最大仓库之一） | `baidunetdisk`、`bilibili`、`dingtalk`、`deeplx`、`netease-cloud-music`、`google-earth-pro`、`wechat-uos`、`one-api` |
| **rycee** | Firefox 扩展（海量） | `darkreader`、`bitwarden`、`ublock-origin`、`bypass-paywalls-clean`、`sponsorblock` |
| **linyinfeng** | RIME 输入法全家桶、Matrix 桥接、开发工具 | `rime-ice`、`rime-luna-pinyin`、`plangothic`、`moe-koe-music` |
| **charmbracelet** | Charmbracelet 终端工具全家桶 | `glow`、`gum`、`vhs`、`freeze`、`mods`、`soft-serve` |
| **mic92** | NixOS 贡献者维护的杂项工具 | `goatcounter`、`vaultwarden_ldap` |
| **0komo** | Lua 工具链、浏览器、Minecraft | `luakit`、`sklauncher`、`plutolang` |
| **artturin** | 通用工具 | 各类杂项包 |

### 搜索 NUR 包

```bash
# CLI 搜索
nix search nur 某关键词

# Web 搜索
# https://nur.nix-community.org  — 377 个仓库，5987+ 个包
```

**优点**：社区共享，不用自己打包，直接声明式引用。
**缺点**：质量参差不齐，可能过期或不可复现。
**注意**：NUR 包不保证长期维护，重要包建议关注上游状态。

---

## C. 源码构建

源码可用时的标准做法。

### Rust 项目

```nix
{ rustPlatform, fetchFromGitHub, ... }:

rustPlatform.buildRustPackage {
  pname = "某工具";
  version = "x.y.z";

  src = fetchFromGitHub {
    owner = "某人";
    repo = "某工具";
    rev = "v${version}";
    hash = "sha256-xxx";  # 先填假值，构建报错后替换
  };

  cargoHash = "sha256-xxx";  # 同上
}
```

**注意**：如果仓库没有 `Cargo.lock`，需要预生成：

```bash
# 本地生成
cd /tmp && curl -sL <source-tarball> | tar xz && cd <dir>
nix shell nixpkgs#cargo nixpkgs#rustc -c cargo generate-lockfile
cp Cargo.lock /path/to/flake/pkgs/某工具-Cargo.lock
```

然后在 derivation 中注入：

```nix
postUnpack = ''
  cp ${./某工具-Cargo.lock} $sourceRoot/Cargo.lock
'';
```

### Go 项目

```nix
{ buildGoModule, fetchFromGitHub, ... }:

buildGoModule {
  pname = "某工具";
  version = "x.y.z";
  src = fetchFromGitHub { ... };
  vendorHash = "sha256-xxx";
}
```

### 其他语言

```nix
stdenv.mkDerivation {
  pname = "某工具";
  version = "x.y.z";
  src = fetchFromGitHub { ... };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ 某些依赖 ];
}
```

**优点**：完全声明式，可复现，可提交 nixpkgs。
**缺点**：需要处理依赖和 hash，维护成本高。
**已有案例**：`mark-shot`（通过 flake input 引入，见下文实战记录）。

---

## D. 预编译二进制 + autoPatchelfHook

有 Linux 预编译 ELF 二进制时使用。

```nix
{ stdenv, fetchurl, autoPatchelfHook, opencv4, libxkbcommon, ... }:

stdenv.mkDerivation {
  pname = "某工具";
  version = "x.y.z";

  src = fetchurl {
    url = "https://github.com/xxx/releases/download/v${version}/某工具-linux-x86_64.tar.gz";
    hash = "sha256-xxx";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ opencv4 libxkbcommon ];  # 运行时动态库依赖

  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin
    cp 某工具 $out/bin/
  '';
}
```

**优点**：简单快速，适合上游只提供二进制的情况。
**缺点**：soname 不匹配时会失败（如需要 libopencv.so.406 但系统只有 .so.413）。
**适用**：动态库版本兼容的预编译二进制。

---

## E. 预编译二进制 + buildFHSEnv（兜底）

闭源软件或 autoPatchelfHook 无法处理时的最后手段。

```nix
{ stdenv, fetchurl, buildFHSEnv, writeShellScriptBin, ... }:

let
  version = "x.y.z";

  src = fetchurl {
    url = "https://example.com/某工具-${version}.tar.gz";
    hash = "sha256-xxx";
  };

  unwrapped = stdenv.mkDerivation {
    pname = "某工具-unwrapped";
    inherit version src;
    dontBuild = true;
    dontPatchELF = true;
    installPhase = ''
      mkdir -p $out/bin
      cp 某工具 $out/bin/
      chmod +x $out/bin/某工具
    '';
  };

  fhsEnv = buildFHSEnv {
    name = "某工具-fhs";
    targetPkgs = p: [ p.glib p.zlib p.stdenv.cc.cc.lib ];
  };
in
writeShellScriptBin "某工具" ''
  exec ${fhsEnv}/bin/某工具-fhs -c "${unwrapped}/bin/某工具" "$@"
''
```

**优点**：万能方案，几乎什么二进制都能跑。
**缺点**：绕过 Nix 隔离机制，不够优雅。
**适用**：闭源软件、AppImage、soname 严重不匹配的情况。

---

## Overlay 引入（C/D/E 通用）

方案 C/D/E 打好的包通过 overlay 注入 nixpkgs：

```nix
# flake.nix
nixpkgs.overlays = [
  (final: prev: {
    某工具 = final.callPackage ./pkgs/某工具.nix { };
  })
];
```

```nix
# home/default.nix
home.packages = [ pkgs.某工具 ];
```

包文件统一放 `pkgs/` 目录：

```
pkgs/
├── 某工具.nix
├── 某工具-Cargo.lock    # 如有
└── 另一个工具.nix
```

---

## 获取 hash 的方法

### fetchFromGitHub / fetchurl

```bash
# 先填假值，构建报错后从错误信息中获取正确 hash
nix build .#... 2>&1 | grep "got:"
```

### cargoHash / vendorHash

```bash
# 同上，填 lib.fakeHash，构建报错后获取
# 错误信息类似：got: sha256-xxx
```

### nix-prefetch-url

```bash
# 对于 tarball
nix-prefetch-url --unpack https://github.com/xxx/yyy/archive/v1.0.tar.gz
# 转换为 SRI
nix hash to-sri --type sha256 <返回的hash>
```

---

## 实战记录：wayscrollshot → mark-shot

**原 wayscrollshot**：Wayland 滚动截图工具（Rust + OpenCV），上游无 Cargo.lock，需本地生成并注入，维护成本高。2026-07 替换为同作者的 `mark-shot`。

**新方案 mark-shot**：Qt 6 / C++ 截图标注工具，上游有 `flake.nix`，通过 flake input 直接引入，无需维护自定义 derivation。

**迁移过程**：
1. 删除 `pkgs/wayscrollshot.nix`、`pkgs/wayscrollshot-Cargo.lock`
2. 添加 `mark-shot.url = "github:jswysnemc/mark-shot"` flake input
3. overlay 中 `mark-shot = mark-shot.packages.${system}.default`
4. 更新 `home/default.nix`、`KEYBINDINGS.md`

**涉及文件**：
- `flake.nix` — flake input + overlay
- `home/default.nix` — home.packages 引用

---

## 维护注意事项

- **升级版本**：更新 `version`、`src.rev`、`src.hash`，重新获取 `cargoHash`/`vendorHash`
- **Cargo.lock 过期**：依赖版本变化时需重新生成
- **flake.lock**：定期 `nix flake update` 更新所有 input
- **NUR 包**：关注上游维护状态，过期则考虑自行打包（回退到方案 C）
- **提交 nixpkgs**：高质量的包建议提交上游，减少本地维护负担
