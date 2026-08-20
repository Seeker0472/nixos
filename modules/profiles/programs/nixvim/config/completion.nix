{
  plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        appearance.nerd_font_variant = "mono";
        completion = {
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 250;
            window.border = "rounded";
          };
          menu.border = "rounded";
        };
        keymap.preset = "super-tab";
        signature = {
          enabled = true;
          window.border = "rounded";
        };
        sources.default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
      };
    };

    friendly-snippets.enable = true;
  };
}
