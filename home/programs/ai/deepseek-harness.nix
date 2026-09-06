{ pkgs, ... }:
{
  home.packages = [ (pkgs.callPackage ../../../pkgs/dsh { }) ];
}
