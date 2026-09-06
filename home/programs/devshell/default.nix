{ pkgs }:
let
  toolchains = import ./toolchains.nix { inherit pkgs; };
  mkShell =
    names:
    let
      selected = map (name: toolchains.${name}) names;
    in
    pkgs.mkShell {
      packages = pkgs.lib.unique (pkgs.lib.concatMap (toolchain: toolchain.packages) selected);
      # inputsFrom previously runs hooks in reverse input order.
      shellHook = pkgs.lib.concatMapStringsSep "\n" (toolchain: toolchain.shellHook or "") (
        pkgs.lib.reverseList selected
      );
    };
  languageNames = builtins.filter (name: name != "base") (builtins.attrNames toolchains);
in
builtins.listToAttrs (
  map (name: {
    inherit name;
    value = mkShell [
      "base"
      name
    ];
  }) languageNames
)
// {
  default = mkShell ([ "base" ] ++ languageNames);
}
