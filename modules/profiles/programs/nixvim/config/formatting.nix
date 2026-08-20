{ lib, ... }:
{
  plugins.conform-nvim = {
    enable = true;
    autoInstall.enable = true;
    settings = {
      default_format_opts = {
        lsp_format = "fallback";
        timeout_ms = 1000;
      };
      format_on_save = lib.nixvim.mkRaw ''
        function(bufnr)
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end

          return { timeout_ms = 1000, lsp_format = "fallback" }
        end
      '';
      formatters_by_ft = {
        bash = [ "shfmt" ];
        json = [ "prettier" ];
        jsonc = [ "prettier" ];
        lua = [ "stylua" ];
        nix = [ "nixfmt" ];
        sh = [ "shfmt" ];
        yaml = [ "prettier" ];
      };
      formatters.shfmt.append_args = [
        "-i"
        "2"
        "-ci"
      ];
      notify_no_formatters = false;
    };
  };

  userCommands = {
    FormatDisable = {
      bang = true;
      desc = "Disable format on save";
      command = lib.nixvim.mkRaw ''
        function(args)
          if args.bang then
            vim.b.disable_autoformat = true
          else
            vim.g.disable_autoformat = true
          end
        end
      '';
    };
    FormatEnable = {
      desc = "Enable format on save";
      command = lib.nixvim.mkRaw ''
        function()
          vim.b.disable_autoformat = false
          vim.g.disable_autoformat = false
        end
      '';
    };
  };
}
