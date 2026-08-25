{ pkgs, ... }:

let
  dsh-web = pkgs.writeShellApplication {
    name = "dsh-web";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.nodejs
    ];
    text = ''
      dsh_version="0.1.0-rc.6"
      dsh_data_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/dsh"
      dsh_entry="$dsh_data_dir/node_modules/.bin/dsh"
      dsh_version_file="$dsh_data_dir/.installed-version"

      installed_version=""
      if [[ -f "$dsh_version_file" ]]; then
        installed_version="$(<"$dsh_version_file")"
      fi

      if [[ ! -x "$dsh_entry" || "$installed_version" != "$dsh_version" ]]; then
        mkdir -p "$dsh_data_dir"
        printf 'dsh-web: installing @deepseek-ai/dsh@%s into %s\n' \
          "$dsh_version" "$dsh_data_dir"
        npm install \
          --prefix "$dsh_data_dir" \
          --no-audit \
          --no-fund \
          --progress=true \
          --loglevel=http \
          "@deepseek-ai/dsh@$dsh_version"
        printf '%s\n' "$dsh_version" > "$dsh_version_file"
        printf 'dsh-web: installation complete\n'
      fi

      exec node --expose-internals "$dsh_entry" web "$@"
    '';
  };
in
{
  home.packages = [ dsh-web ];
}
