{ ... }:
{
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    age.keyFile = "/home/lznauy/.config/sops/age/keys.txt";

    secrets."api_keys/deepseek" = {
      owner = "lznauy";
      group = "users";
    };
    secrets."api_keys/mimo" = {
      owner = "lznauy";
      group = "users";
    };
  };
}
