# Shared desktop policy; host files contain only machine-specific settings.
{
  config,
  inputs,
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
    config.allowUnfree = true;
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
