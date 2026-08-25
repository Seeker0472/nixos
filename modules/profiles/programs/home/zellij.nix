{
  config,
  lib,
  pkgs,
  ...
}:
let
  smartTabs = pkgs.stdenvNoCC.mkDerivation {
    pname = "zellij-smart-tabs";
    version = "0.2.1";

    src = pkgs.fetchurl {
      url = "https://github.com/YesYouKenSpace/zellij-smart-tabs/releases/download/v0.2.1/zellij-smart-tabs.wasm";
      hash = "sha256-l1BQPvIH5yqbm6qoyhMxxcoUcOrpOFR3T0tI/YL7Wpk=";
    };

    dontUnpack = true;
    installPhase = ''
      install -Dm444 "$src" "$out"
    '';

    meta = {
      description = "Automatically names Zellij tabs from their project and running program";
      homepage = "https://github.com/YesYouKenSpace/zellij-smart-tabs";
      license = lib.licenses.mit;
    };
  };
in
{
  config = lib.mkIf config.programs.zellij.enable {
    programs.zellij = {
      plugins = with pkgs.zellijPlugins; [
        vim-zellij-navigator
        zjstatus
        smartTabs
      ];

      settings = {
        default_layout = "dev";
        default_mode = "normal";

        plugins."smart-tabs" = {
          format = "{% if short_git_root %}{{ short_git_root }}{% else %}{{ short_dir }}{% endif %}{% if program %} | {{ program }}{% endif %}";
          poll_interval = "5";
          debounce = "0.2";
          debug = "false";

          # Keep names readable on terminals without a Nerd Font.
          sub.program = {
            bash = "";
            fish = "";
            zsh = "";
            nvim = "nvim";
            vim = "vim";
            lazygit = "git";
            yazi = "files";
          };
        };

        # Keep Zellij's link handler, but render zjstatus only from the layout
        # below instead of starting a second background instance. The navigator
        # is message-triggered and does not need a background instance.
        load_plugins = lib.mkForce {
          _children = [
            { "zellij:link" = [ ]; }
            { "smart-tabs" = [ ]; }
          ];
        };

        keybinds = {
          # Let the navigator pass Ctrl-h/j/k/l into Neovim when appropriate,
          # and move a normal terminal pane otherwise.
          shared_except = {
            _args = [
              "locked"
              "move"
            ];
            _children = [
              {
                bind = {
                  _args = [ "Ctrl h" ];
                  MessagePlugin = {
                    _args = [ "vim-zellij-navigator" ];
                    name = "move_focus_or_tab";
                    payload = "left";
                    move_mod = "ctrl";
                    use_arrow_keys = "false";
                  };
                };
              }
              {
                bind = {
                  _args = [ "Ctrl j" ];
                  MessagePlugin = {
                    _args = [ "vim-zellij-navigator" ];
                    name = "move_focus";
                    payload = "down";
                    move_mod = "ctrl";
                    use_arrow_keys = "false";
                  };
                };
              }
              {
                bind = {
                  _args = [ "Ctrl k" ];
                  MessagePlugin = {
                    _args = [ "vim-zellij-navigator" ];
                    name = "move_focus";
                    payload = "up";
                    move_mod = "ctrl";
                    use_arrow_keys = "false";
                  };
                };
              }
              {
                bind = {
                  _args = [ "Ctrl l" ];
                  MessagePlugin = {
                    _args = [ "vim-zellij-navigator" ];
                    name = "move_focus_or_tab";
                    payload = "right";
                    move_mod = "ctrl";
                    use_arrow_keys = "false";
                  };
                };
              }
            ];
          };

          # A manual rename is kept by smart-tabs until the user explicitly
          # restores automatic naming with Escape.
          tab._children = [
            {
              bind = {
                _args = [ "r" ];
                _children = [
                  {
                    MessagePlugin = {
                      _args = [ "smart-tabs" ];
                      name = "set_focused_to_manual";
                    };
                  }
                  { SwitchToMode._args = [ "renametab" ]; }
                  { TabNameInput._args = [ 0 ]; }
                ];
              };
            }
          ];

          renametab._children = [
            {
              bind = {
                _args = [ "esc" ];
                _children = [
                  { UndoRenameTab = { }; }
                  { SwitchToMode._args = [ "tab" ]; }
                  {
                    MessagePlugin = {
                      _args = [ "smart-tabs" ];
                      name = "set_focused_to_managed";
                    };
                  }
                ];
              };
            }
          ];

          # Ctrl-o then ? opens shortcut tips. A leader sequence keeps ?
          # portable across terminals; Ctrl-o then t opens the smart-tabs
          # dashboard.
          session._children = [
            {
              bind = {
                _args = [ "?" ];
                _children = [
                  {
                    LaunchOrFocusPlugin = {
                      _args = [ "zellij:about" ];
                      _children = [
                        {
                          floating = true;
                          move_to_focused_tab = true;
                          is_startup_tip = "true";
                        }
                      ];
                    };
                  }
                  { SwitchToMode._args = [ "normal" ]; }
                ];
              };
            }
            {
              bind = {
                _args = [ "t" ];
                _children = [
                  {
                    LaunchOrFocusPlugin = {
                      _args = [ "smart-tabs" ];
                      _children = [
                        {
                          floating = true;
                          move_to_focused_tab = true;
                        }
                      ];
                    };
                  }
                  { SwitchToMode._args = [ "normal" ]; }
                ];
              };
            }
          ];
        };
      }
      // lib.optionalAttrs config.programs.fish.enable {
        default_shell = "${config.programs.fish.package}/bin/fish";
      };

      layouts.dev = ''
        layout {
          default_tab_template {
            children

            pane size=1 borderless=true {
              plugin location="zjstatus" {
                format_left   "{mode} {tabs}"
                format_center ""
                format_right  "{session} {datetime}"
                format_space  ""

                format_hide_on_overlength "true"
                format_precedence         "lrc"
                border_enabled            "false"

                mode_normal       "#[fg=#a6e3a1,bold] NORMAL "
                mode_locked       "#[fg=#f38ba8,bold] LOCKED "
                mode_resize       "#[fg=#89b4fa,bold] RESIZE "
                mode_pane         "#[fg=#89b4fa,bold] PANE "
                mode_move         "#[fg=#89b4fa,bold] MOVE "
                mode_tab          "#[fg=#f9e2af,bold] TAB "
                mode_scroll       "#[fg=#cba6f7,bold] SCROLL "
                mode_enter_search "#[fg=#cba6f7,bold] SEARCH "
                mode_search       "#[fg=#cba6f7,bold] SEARCH "
                mode_rename_tab   "#[fg=#f9e2af,bold] RENAME TAB "
                mode_rename_pane  "#[fg=#f9e2af,bold] RENAME PANE "
                mode_session      "#[fg=#f9e2af,bold] SESSION "
                mode_tmux         "#[fg=#fab387,bold] TMUX "

                tab_normal "#[fg=#6c7086]({index}) #[fg=#a6adc8]{name} "
                tab_active "#[fg=#89b4fa,bold]({index}) #[fg=#cdd6f4,bold]{name} "

                datetime          "#[fg=#bac2de]{format} "
                datetime_format   "%Y-%m-%d %H:%M"
                datetime_timezone "Asia/Shanghai"
              }
            }
          }
        }
      '';
    };
  };
}
