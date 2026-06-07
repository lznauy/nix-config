# hyprlock - Wayland 锁屏工具
{
  config,
  pkgs,
  ...
}:
let
  colors = config.lib.stylix.colors;
in
{
  home.packages = with pkgs; [
    hyprlock
  ];

  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        immediate_render = true;
        no_fade_in = true;
        fail_timeout = 2500;
      };

      background = {
        monitor = "";
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
        noise = 0.03;
        contrast = 0.95;
        brightness = 1.02;
      };

      image = {
        monitor = "";
        size = 128;
        rounding = -1;
        border_size = 3;
        border_color = "rgba(${colors.base0C}, 0.8)";
        position = "0, -180";
        halign = "center";
        valign = "center";
        shadow_passes = 2;
        shadow_size = 5;
        shadow_color = "rgba(0, 0, 0, 0.15)";
      };

      label = [
        {
          # 用户名
          monitor = "";
          text = ''<span font_weight="bold">你好，$USER</span>'';
          color = "rgba(${colors.base05}, 0.9)";
          font_size = 24;
          font_family = "Noto Sans CJK SC";
          position = "0, -120";
          halign = "center";
          valign = "center";
        }
        {
          # 时间
          monitor = "";
          text = "cmd[update:1000] echo \"<span font_weight='bold'>$(date +\"%H:%M\")</span>\"";
          color = "rgba(${colors.base06}, 0.95)";
          font_size = 64;
          font_family = "JetBrains Mono Nerd Font";
          position = "0, 0";
          halign = "center";
          valign = "center";
        }
        {
          # 日期
          monitor = "";
          text = "cmd[update:60000] echo \"<span>$(LC_TIME=zh_CN.UTF-8 date +\"%Y年%m月%d日 %A\")</span>\"";
          color = "rgba(${colors.base05}, 0.9)";
          font_size = 18;
          font_family = "Noto Sans CJK SC";
          position = "0, 70";
          halign = "center";
          valign = "center";
        }
        {
          # 系统信息
          monitor = "";
          text = "cmd[update:10000] echo \"<span>$(uname -n) · 运行 $(uptime -p | sed -e 's/up //' -e 's/days/天/' -e 's/hours/小时/' -e 's/minutes/分钟/')\"</span>\"";
          color = "rgba(${colors.base04}, 0.8)";
          font_size = 12;
          font_family = "Noto Sans CJK SC";
          position = "20, -20";
          halign = "left";
          valign = "bottom";
        }
        {
          # 键盘布局
          monitor = "";
          text = "<span>$LAYOUT[EN,中文]</span>";
          color = "rgba(${colors.base0C}, 0.9)";
          font_size = 14;
          font_family = "Noto Sans CJK SC";
          position = "-20, -20";
          halign = "right";
          valign = "bottom";
        }
        {
          # 指纹提示
          monitor = "";
          text = "cmd[update:1000] if [ \"$(systemctl is-active fprintd)\" = \"active\" ]; then echo \"<span font_size='14'>🖐️ 指纹识别就绪</span>\"; fi";
          color = "rgba(${colors.base0C}, 0.9)";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = {
        monitor = "";
        size = "360, 56";
        outline_thickness = 0;
        dots_size = 0.3;
        dots_spacing = 0.15;
        rounding = 28;
        inner_color = "rgba(${colors.base01}, 0.6)";
        font_color = "rgb(${colors.base05})";
        font_family = "JetBrains Mono Nerd Font";
        placeholder_text = "请输入密码...";
        hide_input = false;
        check_color = "rgba(${colors.base0B}, 1.0)";
        fail_color = "rgba(${colors.base08}, 1.0)";
        fail_text = "$FAIL (尝试 $ATTEMPTS 次)";
        position = "0, 150";
        halign = "center";
        valign = "center";
      };
    };
  };
}
