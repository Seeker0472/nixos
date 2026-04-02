{
  lib,
  config,
  pkgs,
  osConfig,
  ...
}:
let
  impermanenceEnabled = lib.attrByPath [
    "machine"
    "impermanence"
    "enable"
  ] false osConfig;
  persistDir = lib.attrByPath [
    "machine"
    "btrfs"
    "impermanence"
    "persistdir"
  ] null osConfig;
in
{
  options.machine.home.zed.enable = lib.mkEnableOption "Enable zed-editor";

  # Note: the following config are ai-generated
  config = lib.mkIf config.machine.home.zed.enable (
    lib.mkMerge [
      (
        if impermanenceEnabled && persistDir != null then
          {
            home.persistence."${persistDir}".directories = [
              ".local/share/keyrings"
              ".local/share/zed"
            ];
          }
        else
          { }
      )
      {
        programs.zed-editor = {
          enable = true;

          extensions = [
            "one-dark-pro"
            "nix"
            "scala"
            "neocmake"
            "make"
          ];

          userSettings = {
            lsp = {
              # --- C / C++ ---
              clangd = {
                binary = {
                  path = "${pkgs.clang-tools}/bin/clangd";
                  arguments = [
                    "--background-index"
                    "--clang-tidy"
                  ];
                };
              };

              # --- Rust ---
              rust-analyzer = {
                binary = {
                  path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
                };
                initialization_options = {
                  checkOnSave = {
                    command = "clippy";
                  };
                };
              };

              # --- Python ---
              pyright = {
                binary = {
                  path = "${pkgs.pyright}/bin/pyright-langserver";
                  arguments = [ "--stdio" ];
                };
              };

              # --- Scala / Chisel ---
              metals = {
                binary = {
                  path = "${pkgs.metals}/bin/metals";
                  arguments = [ ];
                };
                initialization_options = {
                  isHttpEnabled = true;
                  statusBarProvider = "on";
                };
              };

              # --- Nix ---
              nil = {
                binary = {
                  path = "${pkgs.nil}/bin/nil";
                };
              };
            };
            languages = {
              "Nix" = {
                language_servers = [ "nil" ];
                formatter = {
                  external = {
                    command = "${pkgs.nixfmt}/bin/nixfmt";
                  };
                };
              };
              "Python" = {
                language_servers = [ "pyright" ];
              };
              "Scala" = {
                language_servers = [ "metals" ];
                formatter = {
                  language_server = {
                    name = "metals";
                  };
                };
              };
              "C++" = {
                language_servers = [ "clangd" ];
                formatter = {
                  language_server = {
                    name = "clangd";
                  };
                };
              };
              "C" = {
                language_servers = [ "clangd" ];
                formatter = {
                  language_server = {
                    name = "clangd";
                  };
                };
              };
            };
            git = {
              inline_blame = {
                show_commit_summary = false;
              };
            };
            terminal = {
              toolbar = {
                breadcrumbs = false;
              };
              shell = {
                program = "fish";
              };
            };
            active_pane_modifiers = {
              border_size = 2.0;
              inactive_opacity = 0.8;
            };
            tab_bar = {
              show = true;
            };
            tabs = {
              file_icons = false;
              git_status = true;
            };
            title_bar = {
              show_menus = false;
              show_branch_icon = true;
            };
            status_bar = {
              active_language_button = true;
            };
            project_panel = {
              button = true;
            };
            search = {
              include_ignored = false;
            };
            inlay_hints = {
              enabled = true;
            };
            indent_guides = {
              coloring = "indent_aware";
              active_line_width = 2;
              line_width = 1;
            };
            tab_size = 2;
            hard_tabs = false;
            toolbar = {
              code_actions = true;
              selections_menu = true;
              quick_actions = true;
              breadcrumbs = true;
            };
            minimap = {
              max_width_columns = 70;
              current_line_highlight = "all";
              thumb_border = "left_open";
              show = "auto";
            };
            relative_line_numbers = "enabled";
            auto_signature_help = true;
            autosave = "on_window_change";
            ui_font_weight = 500.0;
            buffer_font_family = "Maple Mono NF CN";
            vim_mode = true;
            ui_font_size = 20.0;
            buffer_font_size = 15;
            theme = "One Dark Pro";

            language_models = {
              deepseek = {
                api_url = "https://api.deepseek.com";
                available_models = [
                  {
                    name = "deepseek-chat";
                    display_name = "DeepSeek Chat";
                    max_tokens = 64000;
                  }
                  {
                    name = "deepseek-reasoner";
                    display_name = "DeepSeek Reasoner";
                    max_tokens = 64000;
                    max_output_tokens = 4096;
                  }
                ];
              };
              chatglm = [ ];
            };
          };
        };

        wayland.windowManager.hyprland.settings = {
          windowrule = [ "workspace special:zed,match:class (dev.zed.Zed)" ];
          workspace = [ "special:zed, on-created-empty:[ ] zeditor" ];
          bind = [ "$mainMod,X, togglespecialworkspace,zed" ];
        };
      }
    ]
  );
}
