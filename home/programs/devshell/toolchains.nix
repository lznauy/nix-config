# Plain data shared by Home Manager and nix develop.
{ pkgs }:
{
  base = import ./shells/base.nix { inherit pkgs; };
  python = import ./shells/python.nix { inherit pkgs; };
  node = import ./shells/node.nix { inherit pkgs; };
  go = import ./shells/go.nix { inherit pkgs; };
  rust = import ./shells/rust.nix { inherit pkgs; };
  zig = import ./shells/zig.nix { inherit pkgs; };
}
