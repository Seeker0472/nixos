{ pkgs, lib, ... }: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export YSYX_HOME=/home/seeker/Develop/ysyx-workbench/
    '';

    #     shellAliases = {
    #       k = "kubectl";
    #       urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    #       urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    #     };
  };
}
