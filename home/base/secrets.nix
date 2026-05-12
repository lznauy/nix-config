{ config, ... }:
{
  xdg.configFile."opencode/config.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "/run/agenix/opencode-json";
  };
  home.file.".claude/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "/run/agenix/claude-settings";
  };
}
