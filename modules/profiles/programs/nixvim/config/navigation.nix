{ pkgs, ... }:
{
  extraPackages = with pkgs; [
    fd
    ripgrep
  ];

  plugins = {
    telescope = {
      enable = true;
      highlightTheme = null;
      extensions.fzf-native.enable = true;
      keymaps = {
        "<leader>fb" = {
          action = "buffers";
          options.desc = "Buffers";
        };
        "<leader>ff" = {
          action = "find_files";
          options.desc = "Find files";
        };
        "<leader>fg" = {
          action = "live_grep";
          options.desc = "Grep project";
        };
        "<leader>fh" = {
          action = "help_tags";
          options.desc = "Help tags";
        };
        "<leader>fr" = {
          action = "oldfiles";
          options.desc = "Recent files";
        };
        "<leader>fs" = {
          action = "lsp_document_symbols";
          options.desc = "Document symbols";
        };
        "<leader>fS" = {
          action = "lsp_dynamic_workspace_symbols";
          options.desc = "Workspace symbols";
        };
      };
      settings = {
        defaults = {
          file_ignore_patterns = [
            "^.git/"
            "^node_modules/"
          ];
          layout_config = {
            horizontal.preview_width = 0.55;
            prompt_position = "top";
          };
          layout_strategy = "horizontal";
          path_display = [ "smart" ];
          sorting_strategy = "ascending";
        };
        pickers.find_files.hidden = true;
      };
    };

    trouble = {
      enable = true;
      settings = {
        auto_close = true;
        focus = true;
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<cr>";
      options = {
        desc = "Workspace diagnostics";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>xX";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
      options = {
        desc = "Buffer diagnostics";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>xs";
      action = "<cmd>Trouble symbols toggle focus=false<cr>";
      options = {
        desc = "Document symbols";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>xq";
      action = "<cmd>Trouble qflist toggle<cr>";
      options = {
        desc = "Quickfix list";
        silent = true;
      };
    }
  ];
}
