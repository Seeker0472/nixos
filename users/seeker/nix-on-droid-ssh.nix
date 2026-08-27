{ config, ... }:
let
  sshKeys = import ./ssh-public-keys.nix;
  home = config.home.homeDirectory;
  meshHost = user: {
    User = user;
    IdentityFile = [ config.sops.secrets."ssh-client-private".path ];
    IdentitiesOnly = true;
  };
in
{
  # Reuse the miLaptop identity so both Android devices have the same outbound
  # SSH access. The age key must be provisioned on each device separately.
  sops.age.keyFile = "${home}/.config/sops/age/keys.txt";

  programs.ssh.settings = {
    "*" = {
      IdentityFile = [ config.sops.secrets."ssh-external-private".path ];
      IdentitiesOnly = true;
    };
    DiagonAlley = meshHost "seeker";
    miLaptop = meshHost "seeker";
    devVM = meshHost "seeker";
    nixos-wsl = meshHost "seeker";
    ecos = meshHost "seeker4721";
    "vps.seekerer.com" = {
      IdentityFile = [ config.sops.secrets."ssh-admin-private".path ];
      IdentitiesOnly = true;
    };
  };

  sops.secrets = {
    "ssh-client-private" = {
      sopsFile = sshKeys.files.miLaptop;
      key = "private_key";
      path = "${home}/.ssh/id_mesh";
      mode = "0600";
    };
    "ssh-client-public" = {
      sopsFile = sshKeys.files.miLaptop;
      key = "public_key_unencrypted";
      path = "${home}/.ssh/id_mesh.pub";
      mode = "0644";
    };
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
    "ssh-admin-private" = {
      sopsFile = sshKeys.files.admin;
      key = "private_key";
      path = "${home}/.ssh/id_admin";
      mode = "0600";
    };
    "ssh-admin-public" = {
      sopsFile = sshKeys.files.admin;
      key = "public_key_unencrypted";
      path = "${home}/.ssh/id_admin.pub";
      mode = "0644";
    };
  };
}
