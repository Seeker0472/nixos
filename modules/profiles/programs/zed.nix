{ config, lib, ... }:
let
  # HM-side confg path
  cfgPath = [
    "seeker"
    "home"
    "zed"
  ];

  # get all users
  # config.home-manager.users 是一个 Attribute Set，我们需要将其转为 List
  hmUsers = lib.attrValues config.home-manager.users;

  # lib.getAttrFromPath safely read
  # check if any user enabled
  anyUserEnabled = lib.any (
    userConfig: lib.attrByPath (cfgPath ++ [ "enable" ]) false userConfig
  ) hmUsers;
in
{
  config = lib.mkMerge [
    {
      home-manager.sharedModules = [
        (
          {
            lib,
            config,
            pkgs,
            osConfig,
            ...
          }:
          {
            options.seeker.home.zed.enable = lib.mkEnableOption "Enable zed-editor";

            # Note: the following config are ai-generated
            config = lib.mkIf config.seeker.home.zed.enable {
              home.persistence."${osConfig.seeker.btrfs.impermanence.persistdir}".directories = [
                ".local/share/keyrings"
                ".local/share/zed"
              ];
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
                          "--background-index" # 后台建立索引
                          "--clang-tidy" # 启用代码静态分析
                        ];
                      };
                    };

                    # --- Rust ---
                    rust-analyzer = {
                      binary = {
                        path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
                      };
                      # Rust 特定初始化选项
                      initialization_options = {
                        checkOnSave = {
                          command = "clippy"; # 保存时运行 clippy 而不是简单的 check
                        };
                      };
                    };

                    # --- Python ---
                    pyright = {
                      binary = {
                        path = "${pkgs.pyright}/bin/pyright-langserver";
                        arguments = [ "--stdio" ]; # Pyright 需要指定 stdio 模式
                      };
                    };

                    # --- Scala / Chisel ---
                    metals = {
                      binary = {
                        path = "${pkgs.metals}/bin/metals";
                        # Metals 通常需要一些 Java 参数, 但 Nix 包装版通常处理好了
                        # 如果遇到内存问题，可以在这里通过 arguments 添加 -J-Xmx 等
                        arguments = [ ];
                      };
                      initialization_options = {
                        # 可以在这里配置 Metals 的特定选项
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
                    # Nix 设置
                    "Nix" = {
                      language_servers = [ "nil" ];
                      formatter = {
                        external = {
                          command = "${pkgs.nixfmt}/bin/nixfmt";
                        };
                      };
                    };

                    # Python 设置 (可选：如果你想用 ruff 格式化，需要另外安装 ruff)
                    "Python" = {
                      language_servers = [ "pyright" ];
                    };

                    # Scala / Chisel 设置
                    "Scala" = {
                      language_servers = [ "metals" ];
                      formatter = {
                        language_server = {
                          name = "metals";
                        };
                      };
                    };

                    # C++ 设置
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

                  # TODO: formatter
                  # TAB-space indicator
                  # inlay hints tasks miscellaneous->debuggers
                  # language servers
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
                  };
                };
              };
            };
          }
        )
        {
          wayland.windowManager.hyprland.settings = {
            windowrulev2 = [ "workspace special:zed,class:(dev.zed.Zed)" ];
            workspace = [ "special:zed, on-created-empty:[ ] zeditor" ];
            bind = [ "$mainMod,X, togglespecialworkspace,zed" ];
          };
        }
      ];
    }
    (lib.mkIf anyUserEnabled {
      services.gnome.gnome-keyring.enable = true;
      # auto-decrept
      security.pam.services.login.enableGnomeKeyring = true;

      # warnings = ["Auto-enabling PAM security feature because a user requested it."];
    })
  ];
}
