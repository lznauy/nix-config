{
  inputs,
  pkgs,
  ...
}:
{
  services.flatpak.enable = true;

  environment.systemPackages = [ pkgs.flatpak-builder ];

  home-manager.sharedModules = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

}
