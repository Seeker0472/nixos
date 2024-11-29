{ pkgs,lib, ... }: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO 在这里添加你的自定义 bashrc 内容
    bashrcExtra = ''
      export YSYX_HOME=/home/seeker/Develop/ysyx-workbench/
    '';

    # TODO 设置一些别名方便使用，你可以根据自己的需要进行增删
    #     shellAliases = {
    #       k = "kubectl";
    #       urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    #       urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    #     };
  };
  # 启用 starship，这是一个漂亮的 shell 提示符
  # programs.starship = {
  #   enable = true;
  #   # 自定义配置
  #   settings = {
  #     add_newline = true;
  #     aws.disabled = true;
  #     gcloud.disabled = true;
  #     line_break.disabled = true;
  #     command_timeout = 2000;
  #     nix_shell = {
  #       format = "via [$state (\($name\))]($style)";
  #       symbol = "❄️8";
  #     };
  #   };
  # };




}
