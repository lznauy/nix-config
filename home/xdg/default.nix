{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    xdg-utils # XDG 命令行工具集(open/xdg-open 等)
  ];

  xdg = {
    enable = true;
    userDirs.enable = false;
  };

  programs.bash = {
    enable = true;
    historyFile = "${config.xdg.stateHome}/bash/history";
  };

  home.sessionVariables = {
    GOPATH = "${config.xdg.dataHome}/go";
    PYTHON_HISTORY = "${config.xdg.stateHome}/python/history";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_PREFIX = "${config.xdg.dataHome}/npm";
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
    WGETRC = "${config.xdg.configHome}/wget/wgetrc";
    LESSHISTFILE = "${config.xdg.stateHome}/less/history";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    GNUPGHOME = "${config.xdg.dataHome}/gnupg";

    # hm模块programs.claude-code 模块硬编码写入 ~/.claude/
    # CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
  };

  xdg.configFile."wget/wgetrc".text = ''
    # wget 配置文件
    # 默认空文件，仅用于 XDG base directory 合规
    continue = on
  '';
}
