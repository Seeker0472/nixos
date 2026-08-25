{
  config,
  lib,
  osConfig,
  ...
}:
let
  hostName = osConfig.networking.hostName;
  sshKeys = import ./ssh-public-keys.nix;
  clientSopsFile = sshKeys.files.${hostName} or null;
  deploySecrets = lib.attrByPath [ "machine" "secrets" "deploy" ] true osConfig;
  ageKeyPath = lib.attrByPath [ "machine" "secrets" "ageKeyPath" ] null osConfig;
  isAdminHost = builtins.elem hostName [
    "miLaptop"
    "nixos-wsl"
  ];
  meshHost = user: {
    User = user;
    IdentityFile = [ config.sops.secrets."ssh-client-private".path ];
    IdentitiesOnly = true;
  };
in
lib.mkIf deploySecrets {
  assertions = [
    {
      assertion = clientSopsFile != null;
      message = "No SSH client SOPS file is registered for ${hostName}.";
    }
    {
      assertion = ageKeyPath != null;
      message = "machine.secrets.ageKeyPath is required to deploy SSH keys on ${hostName}.";
    }
  ];

  programs.ssh.settings = {
    "*" = {
      IdentityFile = [ config.sops.secrets."ssh-external-private".path ];
      IdentitiesOnly = true;
    };
    miLaptop = meshHost "seeker";
    devVM = meshHost "seeker";
    nixos-wsl = meshHost "seeker";
    ecos = meshHost "seeker4721";
    "github.com" = {
      IdentityFile = [ config.sops.secrets."ssh-github-private".path ];
      IdentitiesOnly = true;
    };
  }
  // lib.optionalAttrs isAdminHost {
    "vps.seekerer.com" = {
      IdentityFile = [ config.sops.secrets."ssh-admin-private".path ];
      IdentitiesOnly = true;
    };
  };

  sops = {
    age.keyFile = ageKeyPath;
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
      "ssh-client-private" = {
        sopsFile = clientSopsFile;
        key = "private_key";
        path = "${config.home.homeDirectory}/.ssh/id_mesh";
        mode = "0600";
      };
      "ssh-client-public" = {
        sopsFile = clientSopsFile;
        key = "public_key_unencrypted";
        path = "${config.home.homeDirectory}/.ssh/id_mesh.pub";
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
    }
    // lib.optionalAttrs isAdminHost {
      "ssh-admin-private" = {
        sopsFile = sshKeys.files.admin;
        key = "private_key";
        path = "${config.home.homeDirectory}/.ssh/id_admin";
        mode = "0600";
      };
      "ssh-admin-public" = {
        sopsFile = sshKeys.files.admin;
        key = "public_key_unencrypted";
        path = "${config.home.homeDirectory}/.ssh/id_admin.pub";
        mode = "0644";
      };
    };
  };
}
