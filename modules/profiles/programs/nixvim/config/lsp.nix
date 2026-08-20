{ lib, ... }:
{
  plugins = {
    fidget.enable = true;
    lspconfig.enable = true;
    schemastore.enable = true;
  };

  lsp = {
    servers = {
      "*".config.capabilities = lib.nixvim.mkRaw ''require("blink.cmp").get_lsp_capabilities()'';

      bashls.enable = true;
      jsonls.enable = true;
      marksman.enable = true;
      nixd.enable = true;
      yamlls.enable = true;

      lua_ls = {
        enable = true;
        config.settings.Lua = {
          completion.callSnippet = "Replace";
          diagnostics.globals = [ "vim" ];
          hint.enable = true;
          workspace.checkThirdParty = false;
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "gd";
        action = lib.nixvim.mkRaw ''require("telescope.builtin").lsp_definitions'';
        options.desc = "Go to definition";
      }
      {
        mode = "n";
        key = "gr";
        action = lib.nixvim.mkRaw ''require("telescope.builtin").lsp_references'';
        options.desc = "Find references";
      }
      {
        mode = "n";
        key = "gI";
        action = lib.nixvim.mkRaw ''require("telescope.builtin").lsp_implementations'';
        options.desc = "Go to implementation";
      }
      {
        mode = "n";
        key = "gy";
        action = lib.nixvim.mkRaw ''require("telescope.builtin").lsp_type_definitions'';
        options.desc = "Go to type definition";
      }
      {
        mode = "n";
        key = "K";
        lspBufAction = "hover";
        options.desc = "Hover documentation";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>ca";
        lspBufAction = "code_action";
        options.desc = "Code action";
      }
      {
        mode = "n";
        key = "<leader>cr";
        lspBufAction = "rename";
        options.desc = "Rename symbol";
      }
      {
        mode = "n";
        key = "<leader>cf";
        action = lib.nixvim.mkRaw ''
          function()
            require("conform").format({ async = true, lsp_format = "fallback" })
          end
        '';
        options.desc = "Format buffer";
      }
      {
        mode = "n";
        key = "[d";
        action = lib.nixvim.mkRaw ''
          function()
            vim.diagnostic.jump({ count = -1, float = true })
          end
        '';
        options.desc = "Previous diagnostic";
      }
      {
        mode = "n";
        key = "]d";
        action = lib.nixvim.mkRaw ''
          function()
            vim.diagnostic.jump({ count = 1, float = true })
          end
        '';
        options.desc = "Next diagnostic";
      }
      {
        mode = "n";
        key = "<leader>cd";
        action = lib.nixvim.mkRaw "vim.diagnostic.open_float";
        options.desc = "Line diagnostics";
      }
    ];
  };

  diagnostic.settings = {
    severity_sort = true;
    signs = true;
    underline = true;
    update_in_insert = false;
    virtual_text = {
      source = "if_many";
      spacing = 2;
    };
    float = {
      border = "rounded";
      source = "if_many";
    };
  };
}
