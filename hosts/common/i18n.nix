{
  config,
  lib,
  pkgs,
  ...
}:

{
  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "zh_CN.UTF-8";
      LC_IDENTIFICATION = "zh_CN.UTF-8";
      LC_MEASUREMENT = "zh_CN.UTF-8";
      LC_MONETARY = "zh_CN.UTF-8";
      LC_NAME = "zh_CN.UTF-8";
      LC_NUMERIC = "zh_CN.UTF-8";
      LC_PAPER = "zh_CN.UTF-8";
      LC_TELEPHONE = "zh_CN.UTF-8";
      LC_TIME = "zh_CN.UTF-8";
    };
    supportedLocales = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];

  };

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      nerd-fonts.fira-code # FiraCode Nerd Font 等宽字体
      nerd-fonts.jetbrains-mono # JetBrains Mono Nerd Font 等宽字体
      noto-fonts # Google Noto 通用字体
      noto-fonts-cjk-sans # Noto CJK 无衬线字体(中日韩)
      noto-fonts-cjk-serif # Noto CJK 衬线字体(中日韩)
      noto-fonts-color-emoji # Noto 彩色 Emoji 字体
      liberation_ttf # 兼容 Arial / Times New Roman / Courier New
      carlito # 兼容 Calibri
      caladea # 兼容 Cambria
      lxgw-wenkai # 霞鹜文楷 - 楷体
      arphic-ukai # AR PL UKai - 文鼎楷体
      wqy_microhei # 文泉驿微米黑 - 非VF TrueType CJK
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [
          "JetBrainsMono Nerd Font"
        ];
        serif = [ "Noto Serif CJK SC" ];
        sansSerif = [ "WenQuanYi Micro Hei" ];
        emoji = [ "Noto Color Emoji" ];
      };
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <!-- 楷体_GB2312 / 楷体 / KaiTi / KaiTi_GB2312 → LXGW WenKai -->
          <alias><family>楷体_GB2312</family><prefer><family>LXGW WenKai</family><family>AR PL UKai CN</family></prefer></alias>
          <alias><family>楷体</family><prefer><family>LXGW WenKai</family><family>AR PL UKai CN</family></prefer></alias>
          <alias><family>KaiTi</family><prefer><family>LXGW WenKai</family><family>AR PL UKai CN</family></prefer></alias>
          <alias><family>KaiTi_GB2312</family><prefer><family>LXGW WenKai</family><family>AR PL UKai CN</family></prefer></alias>
        </fontconfig>
      '';
    };
  };
}
