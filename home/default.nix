{ config, pkgs, lib, ... }:
{
  home.stateVersion = "26.05";

  imports = [
    ./git.nix
    ./gtk.nix
    ./zsh.nix
    ./nixvim.nix
    ./noctalia.nix
    ./niri.nix
    ./kitty.nix
    ./fcitx5.nix
    ./fastfetch.nix
    ./fuzzel.nix
    ./hyprlock.nix
  ];

home.packages = with pkgs; [
    fastfetch
    tree
    fd
    ripgrep

    zsh-powerlevel10k

    claude-code
    opencode
    mcp-nixos

    git
    gcc
    gnumake
    nodejs
    python3
    go
    tree-sitter

    kitty
    google-chrome
    splayer
  ];
}
