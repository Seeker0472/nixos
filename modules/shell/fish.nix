{ pkgs, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set theme_color_scheme zenburn
      set theme_date_format +"%b/%e|%a %H:%M.%S"
      function fish_greeting; end
      set -g fish_key_bindings fish_vi_key_bindings
      set -g VIRTUAL_ENV_DISABLE_PROMPT 1

      # --- for yazi ---
      function y
      	set tmp (mktemp -t "yazi-cwd.XXXXXX")
      	yazi $argv --cwd-file="$tmp"
      	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
      		builtin cd -- "$cwd"
      	end
      	rm -f -- "$tmp"
      end
    '';
    shellAliases = {
      nfp = "nix-shell --run fish -p";
      gd = "git difftool -d";
      nrs = "sudo nixos-rebuild switch";
      icat = "kitten icat";
      kssh = "kitten ssh";
      kmpv = "mpv --vo=kitty";
    };
    functions = {
      fish_mode_prompt = "";
      _print_git_segment = ''
        # 定义颜色
        set -l color_git_bg $argv[1]

        # 检查是否在 git 仓库中
        git rev-parse --is-inside-work-tree >/dev/null 2>&1
        if test $status -ne 0
            return # 如果不是，就直接退出
        end

        # 获取分支名
        set -l branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
        if [ -z "$branch" ]
            return
        end

        set -l content " $branch"

        # 检查是否有改动
        if not git diff --quiet --ignore-submodules --
          set content "$content*"
        end

        # 调用新的 _prompt_segment, 因为是最后一个段落, 所以 next_bg 是 'normal'
        _prompt_segment $color_git_bg normal $content
      '';
      _prompt_segment = ''
        set -l self_bg $argv[1]
        set -l next_bg $argv[2]
        set -l content $argv[3]

        # 绘制自身背景和内容
        set_color --background $self_bg
        set_color black # 文字颜色
        echo -n " $content "

        # 绘制连接到下一个段落的箭头
        set_color --background $next_bg
        set_color $self_bg
        echo -n ""
      '';

      fish_prompt = ''

        # --- 定义颜色 ---
        set -l color_mode_insert_bg blue
        set -l color_mode_normal_bg magenta
        set -l color_mode_visual_bg green
        set -l color_mode_replace_bg blue
        set -l color_mode_default_bg white

        # set -l color_success_bg green
        set -l color_error_bg red
        set -l color_path_bg cyan
        set -l color_git_bg yellow # maybe more color!
        set -l color_nix_bg green
        set -l color_venv_bg red
        
        # --- 计算各段颜色 ---
        set -l last_status $status

        if test $last_status -eq 0
          set _color_path_bg $color_path_bg
        else
          set _color_path_bg $color_error_bg
        end

        # Git exists
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1
          set _color_git_bg $color_git_bg
        else
          set _color_git_bg normal
        end
        
        # Nix exists(direnv or nix-shell)
        if test -n "$IN_NIX_SHELL"; or test -n "$DIRENV_DIR"
          set _color_nix_bg $color_nix_bg
          set _nix_prompt "󱄅"
          if test -n "$IN_NIX_SHELL" 
            set _nix_prompt "$_nix_prompt "
          end
          if test -n "$DIRENV_DIR"
            set _nix_prompt "$_nix_prompt "
          end
        else
          set _color_nix_bg $_color_git_bg
        end

        # Venv exists
        if test -n "$VIRTUAL_ENV"
          set _color_venv_bg $color_venv_bg
        else
          set _color_venv_bg $_color_nix_bg
        end

        # --- 绘制PROMPT ---

        # 1. [ 模式 ] 段
        set -l mode_bg
        set -l mode_indicator
        switch $fish_bind_mode
            case default 
                set mode_bg $color_mode_default_bg
                set mode_indicator " "
            case insert 
                set mode_bg $color_mode_insert_bg
                set mode_indicator "I"
            case normal
                set mode_bg $color_mode_normal_bg
                set mode_indicator "N"
            case visual
                set mode_bg $color_mode_visual_bg
                set mode_indicator "V"
            case replace_one
                set mode_bg $color_mode_replace_bg
                set mode_indicator "R"
            case '*'
                set mode_bg red
                set mode_indicator $fish_bind_mode
        end

        _prompt_segment $mode_bg $_color_path_bg "$mode_indicator"
        
        # 现在感觉 [ 状态 ]段没有用,把上一条指令的结果显示在路径的背景颜色更高效x
        # 如果模式段的下一个是状态段,就启用这些
        # set -l next_bg_for_mode (if test $last_status -eq 0; echo $color_success_bg; else; echo $color_error_bg; end)
        # _prompt_segment $mode_bg $next_bg_for_mode "$mode_indicator"
        # # 2. [ 状态 ] 段
        # if test $last_status -eq 0
        #     _prompt_segment $color_success_bg $_color_path_bg "✔"
        # else
        #     _prompt_segment $color_error_bg $_color_path_bg "✘"
        # end

        # 3. [ 路径 ] 段
        _prompt_segment $_color_path_bg $_color_venv_bg (prompt_pwd)

        # 4. [ Python venv ]
        if test -n "$VIRTUAL_ENV"
          set -l venv_basename (basename "$VIRTUAL_ENV")
          _prompt_segment $color_venv_bg $_color_nix_bg " $venv_basename"
        end
        
        # 5. [ Nix-venv or Nix-shell ]
        if test -n "$IN_NIX_SHELL"; or test -n "$DIRENV_DIR"
          _prompt_segment $color_nix_bg $_color_git_bg $_nix_prompt
        end

        # 6. [ Git ]
        _print_git_segment $color_git_bg

        # 7. Prompt 结尾
        set_color normal
        echo -n " "
      '';
      fish_right_prompt = ''
        set_color 7d7d7d
        set -l current_time (date +%H:%M)
        echo -n "  $current_time"
        
        if test $CMD_DURATION -gt 500
            set -l duration (math --scale=2 "$CMD_DURATION / 1000")s
            
            # 绘制 RPROMPT
            echo -n " |  $duration"
        end
        set_color normal
      '';
    };
    # plugins = [
    #   # Enable a plugin (here grc for colorized command output) from nixpkgs
    #   { name = "grc"; src = pkgs.fishPlugins.grc.src; }
    #   # Manually packaging and enable a plugin
    #   {
    #     name = "z";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "jethrokuan";
    #       repo = "z";
    #       rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
    #       sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
    #     };
    #   }
    # ];
  };
  home.packages = with pkgs;
    [
      # oh-my-fish
      subversion
    ];
}
