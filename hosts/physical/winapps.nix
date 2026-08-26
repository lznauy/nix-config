{
  inputs,
  pkgs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;

  # Avoid storing the Windows password in the Nix store or Git. FreeRDP calls
  # this helper for each new connection and receives the password on stdout.
  winappsAskpass = pkgs.writeShellApplication {
    name = "winapps-rdp-askpass";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.zenity
    ];
    text = ''
      cache_file="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/winapps-rdp-password"

      if [[ -r "$cache_file" ]]; then
        cat "$cache_file"
        exit 0
      fi

      password="$(zenity --password --title="WinApps" --text="请输入 Windows 虚拟机密码")"
      umask 077
      printf '%s' "$password" > "$cache_file"
      printf '%s' "$password"
    '';
  };

in
{
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  environment.systemPackages = [
    pkgs.freerdp
    inputs.winapps.packages.${system}.winapps
    inputs.winapps.packages.${system}.winapps-launcher
    winappsAskpass
  ];

  # The default WinApps command connects to the Docker-backed Windows VM.
  # The Windows username is intentionally easy to change here; its password is
  # requested graphically and never becomes part of the Nix store.
  home-manager.users.lznauy.xdg.configFile."winapps/winapps.conf" = {
    force = true;
    text = ''
      RDP_USER="lznauy"
      RDP_PASS="admin@123"
      RDP_ASKPASS="${winappsAskpass}/bin/winapps-rdp-askpass"
      RDP_DOMAIN=""

      RDP_IP="127.0.0.1"
      RDP_PORT="3389"
      VM_NAME="WinApps"
      WAFLAVOR="docker"

      RDP_SCALE="140"
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
