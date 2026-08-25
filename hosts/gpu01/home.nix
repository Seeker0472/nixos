{
  config,
  lib,
  pkgs,
  ...
}:
let
  sshKeys = import ../../users/seeker/ssh-public-keys.nix;
  authorizedKeysFile = pkgs.writeText "gpu01-authorized-keys" (
    builtins.concatStringsSep "\n" sshKeys.authorizedKeys + "\n"
  );
in
{
  home.username = "seeker4721";
  home.homeDirectory = "/home/seeker4721";

  machine.programs.nixvim.development.enable = true;

  programs.ssh.settings."*" = {
    IdentityFile = [ config.sops.secrets."ssh-external-private".path ];
    IdentitiesOnly = true;
  };

  programs.ssh.settings."github.com" = {
    IdentityFile = [ config.sops.secrets."ssh-github-private".path ];
    IdentitiesOnly = true;
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets = {
      "ssh-external-private" = {
        sopsFile = sshKeys.files.external;
        key = "private_key";
        path = "${config.home.homeDirectory}/.ssh/id_external";
        mode = "0600";
      };
      "ssh-external-public" = {
        sopsFile = sshKeys.files.external;
        key = "public_key_unencrypted";
        path = "${config.home.homeDirectory}/.ssh/id_external.pub";
        mode = "0644";
      };
      "ssh-github-private" = {
        sopsFile = sshKeys.files.github;
        key = "private_key";
        path = "${config.home.homeDirectory}/.ssh/id_github";
        mode = "0600";
      };
      "ssh-github-public" = {
        sopsFile = sshKeys.files.github;
        key = "public_key_unencrypted";
        path = "${config.home.homeDirectory}/.ssh/id_github.pub";
        mode = "0644";
      };
    };
  };

  # OpenSSH StrictModes rejects symlinks into this cluster's shared Nix store,
  # whose paths are not owned by seeker4721 or root. Install a user-owned file.
  home.activation.installAuthorizedKeys = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -d -m 0700 "$HOME/.ssh"
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -m 0600 \
      ${authorizedKeysFile} "$HOME/.ssh/.authorized_keys.home-manager"
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv -fT \
      "$HOME/.ssh/.authorized_keys.home-manager" "$HOME/.ssh/authorized_keys"
  '';

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
