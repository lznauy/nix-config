# Shared desktop policy; host files contain only machine-specific settings.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  user = import ../config/user.nix;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
    ../hosts/common/base.nix
    ../hosts/common/i18n.nix
    ../hosts/common/clash-verge.nix
    ../hosts/common/flatpak.nix
    ../hosts/common/xwayland.nix
    ../hosts/common/secrets
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      # splayer 依赖的 electron 大版本被 nixpkgs 标记为 EOL。按"名字+主版本"放行：
      # 补丁版升级(41.10.7→41.11.x)不再需要改这里；换大版本(41→42)时会再次
      # 提示拒绝，那时应确认 splayer 是否已跟进新 electron 再放行。
      allowInsecurePredicate =
        pkg: (pkg.pname or null) == "electron" && lib.versions.major (pkg.version or "") == "41";
    };
    overlays = [
      inputs.claude-code.overlays.default
      inputs.nur.overlays.default
      (import ../overlays { inherit inputs; })
    ];
  };

  nix.settings = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      inputs.nixvim.homeModules.nixvim
      inputs.noctalia.homeModules.default
      inputs.stylix.homeModules.stylix
    ];
    users.${user.name} = import ../home;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  virtualisation.docker.enable = true;

  users.users.${user.name} = {
    isNormalUser = true;
    shell = pkgs.fish;
    inherit (user) home;
    extraGroups = [
      "wheel"
      "users"
      "networkmanager"
      "docker"
    ];
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;

  programs.niri.enable = true;

  # greetd + tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%Y-%m-%d %H:%M' --remember --remember-session --sessions '${config.services.displayManager.sessionData.desktops}/share/wayland-sessions' --cmd niri-session";
      };
    };
  };

  environment.sessionVariables = {
    QS_ICON_THEME = "WhiteSur-dark";
  };

  services.openssh.settings.AllowUsers = [ user.name ];
}
