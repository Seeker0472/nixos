{ config, ... }:
let
  sshKeys = import ./ssh-public-keys.nix;
  home = config.home.homeDirectory;
in
{
  programs.ssh.settings = {
    "*" = {
      IdentityFile = [ config.sops.secrets."ssh-external-private".path ];
      IdentitiesOnly = true;
    };
    "github.com" = {
      IdentityFile = [ config.sops.secrets."ssh-github-private".path ];
      IdentitiesOnly = true;
    };
  };

  sops.secrets = {
    "ssh-external-private" = {
      sopsFile = sshKeys.files.external;
      key = "private_key";
      path = "${home}/.ssh/id_external";
      mode = "0600";
    };
    "ssh-external-public" = {
      sopsFile = sshKeys.files.external;
      key = "public_key_unencrypted";
      path = "${home}/.ssh/id_external.pub";
      mode = "0644";
    };
    "ssh-github-private" = {
      sopsFile = sshKeys.files.github;
      key = "private_key";
      path = "${home}/.ssh/id_github";
      mode = "0600";
    };
    "ssh-github-public" = {
      sopsFile = sshKeys.files.github;
      key = "public_key_unencrypted";
      path = "${home}/.ssh/id_github.pub";
      mode = "0644";
    };
  };
}
