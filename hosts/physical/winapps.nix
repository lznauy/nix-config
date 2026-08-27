{
  inputs,
  pkgs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  environment.systemPackages = [
    pkgs.freerdp
    inputs.winapps.packages.${system}.winapps
    inputs.winapps.packages.${system}.winapps-launcher
  ];

  # The default WinApps command connects to the Docker-backed Windows VM.
  home-manager.users.lznauy.xdg.configFile."winapps/winapps.conf" = {
    force = true;
    text = ''
      RDP_USER="lznauy"
      RDP_PASS="admin@123"
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
