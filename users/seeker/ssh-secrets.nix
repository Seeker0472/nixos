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
  deploySecrets = lib.attrByPath [ "machine" "secrets" "deploy" ] false osConfig;
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
{
  imports = lib.optional deploySecrets ./ssh-client-secrets.nix;

  config = lib.mkIf deploySecrets {
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
      miLaptop = meshHost "seeker";
      devVM = meshHost "seeker";
      nixos-wsl = meshHost "seeker";
      ecos = meshHost "seeker4721";
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
  };
}
