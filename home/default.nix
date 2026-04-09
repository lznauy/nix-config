{ config, pkgs, ... }:
{
  home.stateVersion = "26.05";

  imports = [
    ./git.nix
    ./zsh.nix
    ./nvchad.nix
    ./noctalia.nix
  ];

  home.packages = with pkgs; [
    fastfetch
    tree
    fd
    ripgrep

    zsh-powerlevel10k
    nerd-fonts.jetbrains-mono

    claude-code
    opencode
    mcp-nixos

    git
    gcc
    gnumake
    nodejs
    python3
    go
  ];
}
