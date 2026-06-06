# OnlyOffice — 桌面办公套件
# FHS 沙箱运行，不使用系统 fontconfig，需要手动拷贝 CJK 字体到 ~/.local/share/fonts/
{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.onlyoffice-desktopeditors ];

  home.activation.linkOnlyofficeFonts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    fonts_dir="$HOME/.local/share/fonts"
    $DRY_RUN_CMD mkdir -p $fonts_dir
    for f in ${pkgs.lxgw-wenkai}/share/fonts/truetype/*.ttf; do
      $DRY_RUN_CMD cp -f "$f" "$fonts_dir/"
    done
    for f in ${pkgs.wqy_microhei}/share/fonts/truetype/*.ttc; do
      $DRY_RUN_CMD cp -f "$f" "$fonts_dir/"
    done
    for f in ${pkgs.arphic-ukai}/share/fonts/truetype/*.ttc; do
      $DRY_RUN_CMD cp -f "$f" "$fonts_dir/"
    done
    # 清除 OnlyOffice 字体缓存，强制重新扫描
    oo_fonts_cache="$HOME/.local/share/onlyoffice/desktopeditors/data/fonts"
    $DRY_RUN_CMD rm -f "$oo_fonts_cache/AllFonts.js" "$oo_fonts_cache/AllFonts.js."*
    $DRY_RUN_CMD rm -f "$oo_fonts_cache/fonts.log" "$oo_fonts_cache/font_selection.bin"
  '';
}
