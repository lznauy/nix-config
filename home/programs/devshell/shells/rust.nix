# Rust 开发环境
{ pkgs }:
{
  packages = with pkgs; [
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt
    bacon
    cargo-edit
    cargo-watch
  ];

  shellHook = ''
    echo "🦀 Rust $(rustc --version | cut -d' ' -f2) 已加载"
  '';
}
