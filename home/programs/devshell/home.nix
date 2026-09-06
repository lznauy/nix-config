{ pkgs, ... }:
let
  toolchains = import ./toolchains.nix { inherit pkgs; };
in
{
  home.packages = pkgs.lib.unique (
    pkgs.lib.concatMap (toolchain: toolchain.packages) (builtins.attrValues toolchains)
  );
}
