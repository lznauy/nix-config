# 从 devshell 导入，供 flake.nix 暴露为 devShells
{ pkgs }:
import ./home/programs/devshell/default.nix { inherit pkgs; }
