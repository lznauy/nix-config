{ inputs }:
final: prev:
let
  system = prev.stdenv.hostPlatform.system;
  importPackages =
    input:
    import input {
      inherit system;
      inherit (prev) config;
    };
  unstablePkgs = importPackages inputs.nixpkgs-unstable;
  cachedPkgs = importPackages inputs.nixpkgs-cached;
in
{
  # 使用完整上游包集，避免 override 改变构建路径而失去二进制缓存。
  inherit (unstablePkgs) witr tailcat;
  # AI agent 工作流工具：主分支旧版 agent-browser 不带 chromium，unstable 带包装。
  inherit (unstablePkgs) worktrunk agent-browser;
  inherit (cachedPkgs) clash-verge-rev;
  claude-code = inputs.llm-agents.packages.${system}.claude-code;

  # vscode 1.144.0 起上游把内置 ripgrep 换成 @vscode/ripgrep-universal，
  # 而 nixpkgs 26.05 的 generic.nix 仍写死 @vscode/ripgrep/bin/rg，
  # patchPhase 里的 rm 直接报 No such file or directory。
  # unstable 已按 vscodeVersion 分支处理路径，上游回落后可删掉这段。
  # vscode 是 unfree 包，必须走带 config 的实例（裸 legacyPackages 会在 eval 阶段被拦）。
  inherit (unstablePkgs) vscode;

  # 官方固定版本二进制只做重打包，不再本地编译 Go / C++ / Rust。
  quien = final.callPackage ../pkgs/quien { };
  mark-shot = unstablePkgs.callPackage ../pkgs/mark-shot { };
  splayer-next = final.callPackage ../pkgs/splayer-next { };
  # QQNT — 版本锁定
  qq = final.callPackage ../pkgs/qq { inherit (prev) qq; };
}
