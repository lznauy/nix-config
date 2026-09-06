{
  config,
  inputs,
  pkgs,
  ...
}:

let
  user = import ../../config/user.nix;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  environment.systemPackages = [
    pkgs.freerdp
    inputs.winapps.packages.${system}.winapps
    inputs.winapps.packages.${system}.winapps-launcher
  ];

  sops.secrets."winapps/password" = {
    owner = user.name;
    inherit (user) group;
  };
  sops.templates."winapps.env" = {
    owner = user.name;
    inherit (user) group;
    content = "PASSWORD=${config.sops.placeholder."winapps/password"}\n";
  };

  # The default WinApps command connects to the Docker-backed Windows VM.
  home-manager.users.${user.name}.xdg.configFile."winapps/winapps.conf" = {
    force = true;
    text = ''
      RDP_USER="${user.name}"
      RDP_PASS="$(cat ${config.sops.secrets."winapps/password".path})"
      RDP_ASKPASS=""
      RDP_DOMAIN=""

      RDP_IP="127.0.0.1"
      RDP_PORT="3389"
      VM_NAME="WinApps"
      WAFLAVOR="docker"

      RDP_SCALE="180"
      REMOVABLE_MEDIA="/run/media"
      RDP_FLAGS="/cert:tofu /sound /microphone +home-drive"
      RDP_FLAGS_NON_WINDOWS=""
      RDP_FLAGS_WINDOWS=""

      DEBUG="true"
      AUTOPAUSE="off"
      AUTOPAUSE_TIME="300"
      FREERDP_COMMAND="${pkgs.freerdp}/bin/xfreerdp"
      PORT_TIMEOUT="10"
      RDP_TIMEOUT="30"
    '';
  };
}
