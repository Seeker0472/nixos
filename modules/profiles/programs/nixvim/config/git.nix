{ lib, ... }:
{
  plugins = {
    gitsigns = {
      enable = true;
      settings = {
        attach_to_untracked = true;
        current_line_blame = false;
        preview_config.border = "rounded";
        on_attach = lib.nixvim.mkRaw ''
          function(bufnr)
            local gitsigns = require("gitsigns")

            local function map(mode, key, action, desc)
              vim.keymap.set(mode, key, action, {
                buffer = bufnr,
                desc = desc,
                silent = true,
              })
            end

            map("n", "]h", function()
              if vim.wo.diff then
                vim.cmd.normal({ "]c", bang = true })
              else
                gitsigns.nav_hunk("next")
              end
            end, "Next Git hunk")

            map("n", "[h", function()
              if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
              else
                gitsigns.nav_hunk("prev")
              end
            end, "Previous Git hunk")

            map("n", "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
            map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
            map("n", "<leader>hS", gitsigns.stage_buffer, "Stage buffer")
            map("n", "<leader>hR", gitsigns.reset_buffer, "Reset buffer")
            map("n", "<leader>hu", gitsigns.undo_stage_hunk, "Undo stage hunk")
            map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk")
            map("n", "<leader>hb", function()
              gitsigns.blame_line({ full = true })
            end, "Blame line")
            map("n", "<leader>hB", gitsigns.toggle_current_line_blame, "Toggle line blame")
            map("n", "<leader>hd", gitsigns.diffthis, "Diff against index")

            map("x", "<leader>hs", function()
              gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, "Stage selected hunk")
            map("x", "<leader>hr", function()
              gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, "Reset selected hunk")
          end
        '';
      };
    };

    lazygit = {
      enable = true;
      settings = {
        floating_window_scaling_factor = 0.9;
        floating_window_winblend = 0;
      };
    };

    telescope.keymaps = {
      "<leader>gb" = {
        action = "git_branches";
        options.desc = "Git branches";
      };
      "<leader>gc" = {
        action = "git_commits";
        options.desc = "Git commits";
      };
      "<leader>gs" = {
        action = "git_status";
        options.desc = "Git status";
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>LazyGit<cr>";
      options = {
        desc = "Lazygit";
        silent = true;
      };
    }
  ];
}
