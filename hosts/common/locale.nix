{ pkgs, ... }:
{
  time.timeZone = "Asia/Shanghai";
  i18n = {
    # 完整归档有官方缓存；避免为仅中英文的集合重新生成 glibc-locales。
    inherit (pkgs) glibcLocales;
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };
}
