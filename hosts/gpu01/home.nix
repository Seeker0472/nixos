{ config, ... }:
{
  home.username = "seeker4721";
  home.homeDirectory = "/home/seeker4721";

  machine.programs.nixvim.development.enable = true;

  # The cluster owns /etc/passwd; hand interactive login shells to Fish here.
  programs.bash.profileExtra = ''
    case $- in
      *i*)
        if [ -t 0 ] \
          && [ -t 1 ] \
          && [ -n "''${SSH_TTY-}" ] \
          && [ -z "''${SSH_ORIGINAL_COMMAND-}" ] \
          && [ "''${TERM_PROGRAM-}" != "vscode" ] \
          && [ -z "''${VSCODE_IPC_HOOK_CLI-}" ]; then
          exec ${config.programs.fish.package}/bin/fish
        fi
        ;;
    esac
  '';
}
