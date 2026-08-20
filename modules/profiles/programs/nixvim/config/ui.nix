{
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      flavour = "mocha";
      term_colors = true;
      integrations = {
        mini = {
          enabled = true;
          indentscope_color = "";
        };
        which_key = true;
      };
    };
  };

  plugins.which-key = {
    enable = true;
    settings = {
      delay = 300;
      preset = "modern";
      spec = [
        {
          __unkeyed-1 = "<leader>b";
          group = "buffer";
        }
        {
          __unkeyed-1 = "<leader>c";
          group = "code";
        }
        {
          __unkeyed-1 = "<leader>f";
          group = "find";
        }
        {
          __unkeyed-1 = "<leader>g";
          group = "git";
        }
        {
          __unkeyed-1 = "<leader>h";
          group = "hunks";
        }
        {
          __unkeyed-1 = "<leader>x";
          group = "diagnostics";
        }
      ];
      win.border = "rounded";
    };
  };
}
