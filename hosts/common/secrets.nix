{ config, ... }:
{
  age.identityPaths = [ "/home/lznauy/.config/sops/age/keys.txt" ];

  age.secrets.opencode-json = {
    file = ../../secrets/opencode.json.age;
    owner = "lznauy";
    group = "users";
  };

  age.secrets.claude-settings-deepseek = {
    file = ../../secrets/claude-settings-deepseek.json.age;
    owner = "lznauy";
    group = "users";
  };

  age.secrets.claude-settings-mimo = {
    file = ../../secrets/claude-settings-mimo.json.age;
    owner = "lznauy";
    group = "users";
  };
}
