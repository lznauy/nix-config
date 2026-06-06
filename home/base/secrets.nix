{ config, ... }:
{
  xdg.configFile."opencode/config.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "/run/agenix/opencode-json";
  };
  home.file.".claude/settings-deepseek.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "/run/agenix/claude-settings-deepseek";
  };
  home.file.".claude/settings-mimo.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "/run/agenix/claude-settings-mimo";
  };
}
