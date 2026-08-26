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

  home-manager.users.lznauy.services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    packages = [
      {
        appId = "cn.feishu.Feishu";
        origin = "flathub";
      }

      # NekoCode 的 Flatpak 构建环境；与 build/flatpak manifest 保持一致。
      {
        appId = "org.gnome.Platform//50";
        origin = "flathub";
      }
      {
        appId = "org.gnome.Sdk//50";
        origin = "flathub";
      }
    ];
  };
}
