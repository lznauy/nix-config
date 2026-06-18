{
  config,
  lib,
  pkgs,
  ...
}:

let
  starshipBaseConfig = "${config.xdg.configHome}/starship/base.toml";
  starshipRuntimeConfig = "${config.xdg.cacheHome}/noctalia/starship.toml";
  starshipPalette = "${config.xdg.cacheHome}/noctalia/starship-palette.toml";
  fallbackStarshipPalette = ''
    # Fallback palette used before Noctalia generates ~/.cache/noctalia/starship-palette.toml.

    [palettes.noctalia]
    rosewater = "#f8fafc"
    flamingo = "#e2e8f0"
    pink = "#c7d2fe"
    mauve = "#a5b4fc"
    red = "#f87171"
    maroon = "#fb7185"
    peach = "#fbbf24"
    yellow = "#fbbf24"
    green = "#34d399"
    teal = "#5eead4"
    sky = "#7dd3fc"
    sapphire = "#38bdf8"
    blue = "#7dd3fc"
    lavender = "#a5b4fc"
    text = "#e2e8f0"
    subtext1 = "#cbd5e1"
    subtext0 = "#94a3b8"
    overlay2 = "#64748b"
    overlay1 = "#475569"
    overlay0 = "#334155"
    surface2 = "#1f2937"
    surface1 = "#111827"
    surface0 = "#0f172a"
    base = "#0b0f14"
    mantle = "#0b0f14"
    crust = "#0b0f14"
  '';
in
{
  home.packages = [ pkgs.starship ]; # 跨 shell 美化提示符

  home.sessionVariables.STARSHIP_CONFIG = lib.mkForce starshipRuntimeConfig;

  xdg.configFile."starship/base.toml" = {
    source = ./starship.toml;
    force = true;
  };

  home.activation.seedNoctaliaStarshipConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    runtime_config="${starshipRuntimeConfig}"
    base_config="${starshipBaseConfig}"
    base_stamp="${starshipRuntimeConfig}.base"
    palette_file="${starshipPalette}"

    if [ ! -f "$runtime_config" ] || [ ! -w "$runtime_config" ] || ! cmp -s "$base_config" "$base_stamp" || ! grep -q '^\[palettes\.noctalia\]' "$runtime_config"; then
      mkdir -p "$(dirname "$runtime_config")"
      install -m 0644 "$base_config" "$runtime_config"
      install -m 0644 "$base_config" "$base_stamp"

      {
        printf '\n# >>> NOCTALIA STARSHIP PALETTE >>>\n'
        if [ -f "$palette_file" ]; then
          cat "$palette_file"
        else
          cat <<'NOCTALIA_STARSHIP_FALLBACK'
    ${fallbackStarshipPalette}
    NOCTALIA_STARSHIP_FALLBACK
        fi
        printf '# <<< NOCTALIA STARSHIP PALETTE <<<\n'
      } >> "$runtime_config"
    fi
  '';

  programs.fish = {
    enable = true;
    shellInit = "set -x TERM xterm-256color";
    interactiveShellInit = ''
      set fish_greeting
    '';
    functions = {
      claude-ds = {
        body = "command claude --settings ~/.claude/settings-deepseek.json $argv";
      };
      claude-mimo = {
        body = "command claude --settings ~/.claude/settings-mimo.json $argv";
      };
      opencode = {
        body = "command opencode -m deepseek/deepseek-v4-pro $argv";
      };
      opencode-mimo = {
        body = "command opencode -m mimo/mimo-v2.5-pro $argv";
      };
    };
  };

  programs.starship = {
    enable = true;
    package = pkgs.starship;
  };
}
