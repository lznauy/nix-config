# Evaluate all hosts and run formatting, static checks, and existing tests.
check:
    nix flake check path:.

# Run only the existing JS/Python tests with pinned tools.
test:
    nix build --no-link path:.#checks.x86_64-linux.tests

# Evaluate complete system derivations without building or activating them.
eval:
    nix eval --json path:.#nixosConfigurations --apply 'builtins.mapAttrs (_: host: host.config.system.build.toplevel.drvPath)'

# Format Nix files using the formatter pinned by the flake.
fmt:
    nix run path:.#formatter.x86_64-linux -- --tree-root . --walk filesystem
