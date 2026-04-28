# nixvim - Nix 管理的 Neovim 配置
{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    tree-sitter # 语法解析器生成器（nixvim treesitter 依赖）
  ];

  programs.nixvim = {
    enable = true;

    defaultEditor = true;

    viAlias = true;
    vimAlias = true;

    # Leader key
    leader = " ";

    # Options
    opts = {
      number = lib.mkDefault true;
      relativenumber = lib.mkDefault true;
      mouse = "a";
      clipboard = "unnamedplus";
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
    };

    # Keymaps
    keymaps = import ./keymaps.nix;

    # Plugins
    plugins = {
      web-devicons.enable = true;
      startupify.enable = true;
      neo-tree.enable = true;
      vim-surround.enable = true;
      gitsigns.enable = true;
      telescope.enable = true;
      treesitter = {
        enable = true;
        ensureInstalled = [
          "lua"
          "bash"
          "python"
          "vim"
          "vimdoc"
          "nix"
          "go"
          "javascript"
          "typescript"
          "tsx"
          "json"
          "html"
          "css"
        ];
        highlight = {
          enable = true;
        };
        indent = {
          enable = false;
        };
      };

      # LSP 服务器
      lsp = {
        enable = true;
        servers = {
          # Nix
          nil_ls.enable = true;
          # Bash
          bashls.enable = true;
          # Python
          pyright.enable = true;
          # Go
          gopls.enable = true;
          # JavaScript / TypeScript
          ts_ls.enable = true;
          # JSON
          jsonls.enable = true;
          # HTML / CSS
          html.enable = true;
          cssls.enable = true;
        };
      };

      # 补全
      cmp = {
        enable = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          mapping = {
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_next_item() else fallback() end end, { 'i', 's' })";
            "<S-Tab>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_prev_item() else fallback() end end, { 'i', 's' })";
          };
        };
      };
      cmp-nvim-lsp.enable = true;
      cmp-path.enable = true;
      cmp-buffer.enable = true;
    };
  };
}
