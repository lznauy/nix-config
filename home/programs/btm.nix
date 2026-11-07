# bottom - 终端系统资源监控工具
{ config, ... }:
let
  colors = config.lib.stylix.colors;
in
{
  programs.bottom = {
    enable = true;
    settings = {
      flags = {
        process_memory_as_value = true;
        tree = true;
        enable_gpu = true;
      };

      network.use_log = false;
      memory.cache_memory = true;

      processes = {
        columns = [
          "PID"
          "Name"
          "CPU%"
          "Mem%"
          "R/s"
          "W/s"
          "T.Read"
          "T.Write"
          "User"
          "State"
          "GMem%"
          "GPU%"
        ];
      };

      styles = {
        tables = {
          headers = {
            color = "#${colors.base0C}";
          };
        };

        cpu = {
          all_entry_color = "#${colors.base05}";
          avg_entry_color = "#${colors.base09}";
          cpu_core_colors = [
            "#${colors.base0E}"
            "#${colors.base0F}"
            "#${colors.base0A}"
            "#${colors.base0B}"
            "#${colors.base0C}"
            "#${colors.base09}"
            "#${colors.base08}"
            "#${colors.base03}"
          ];
        };

        memory = {
          ram_color = "#${colors.base0B}";
          swap_color = "#${colors.base0F}";
          gpu_colors = [
            "#${colors.base0E}"
            "#${colors.base0F}"
            "#${colors.base09}"
            "#${colors.base0C}"
            "#${colors.base0B}"
            "#${colors.base0A}"
          ];
          arc_color = "#${colors.base0C}";
        };

        network = {
          rx_color = "#${colors.base0B}";
          tx_color = "#${colors.base0F}";
        };

        widgets = {
          widget_title = {
            color = "#${colors.base0E}";
          };
          border_color = "#${colors.base01}";
          selected_border_color = "#${colors.base0E}";
          text = {
            color = "#${colors.base05}";
          };
          selected_text = {
            color = "#${colors.base00}";
            bg_color = "#${colors.base0E}";
          };
        };

        graphs = {
          graph_color = "#${colors.base01}";
        };

        battery = {
          high_battery_color = "#${colors.base0B}";
          medium_battery_color = "#${colors.base0A}";
          low_battery_color = "#${colors.base08}";
        };
      };
    };
  };
}
