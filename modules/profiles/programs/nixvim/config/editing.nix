{ lib, ... }:
{
  plugins.mini = {
    enable = true;
    mockDevIcons = true;
    modules = {
      ai = {
        n_lines = 500;
        search_method = "cover_or_nearest";
      };
      bufremove = { };
      icons = { };
      pairs.modes = {
        command = false;
        insert = true;
        terminal = false;
      };
      statusline.use_icons = true;
      surround = {
        n_lines = 100;
        mappings = {
          add = "gsa";
          delete = "gsd";
          find = "gsf";
          find_left = "gsF";
          highlight = "gsh";
          replace = "gsr";
          update_n_lines = "gsn";
        };
      };
    };
  };

  autoGroups = {
    nixvim_create_parent.clear = true;
    nixvim_yank_highlight.clear = true;
  };

  autoCmd = [
    {
      event = "TextYankPost";
      group = "nixvim_yank_highlight";
      desc = "Highlight copied text";
      callback = lib.nixvim.mkRaw ''
        function()
          vim.highlight.on_yank({ timeout = 200 })
        end
      '';
    }
    {
      event = "BufWritePre";
      group = "nixvim_create_parent";
      desc = "Create missing parent directories before writing";
      callback = lib.nixvim.mkRaw ''
        function(args)
          local file = vim.api.nvim_buf_get_name(args.buf)
          if file == "" or file:match("^%w%w+://") then
            return
          end

          vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
        end
      '';
    }
  ];
}
