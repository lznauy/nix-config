{ ... }:
{
  imports = [
    ../../profiles/desktop.nix
  ];

  networking.hostName = "nixos";
  networking.proxy.default = "http://192.168.1.142:7897/";
  networking.proxy.noProxy = "127.0.0.1,localhost";

  virtualisation.vmware.guest.enable = true;

}
