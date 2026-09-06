# OnlyOffice's FHS environment needs real font files in the user font directory.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  fonts = pkgs.symlinkJoin {
    name = "onlyoffice-fonts";
    paths = [
      pkgs.lxgw-wenkai
      pkgs.wqy_microhei
      pkgs.arphic-ukai
    ];
  };
in
{
  home.packages = [ pkgs.onlyoffice-desktopeditors ];
  home.activation.linkOnlyofficeFonts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.bash}/bin/bash ${./onlyoffice-fonts.sh} \
      ${lib.escapeShellArg config.xdg.dataHome} ${fonts}
  '';
}
