{
  inputs,
  pkgs,
  ...
}:
let
  sshKeys = import ./ssh-public-keys.nix;
in
{
  imports = [ ../home-manager.nix ];

  machine.users.seeker.authorizedKeys = sshKeys.authorizedKeys;

  programs.fish.enable = true;
  users.users.seeker.shell = pkgs.fish;

  home-manager.users.seeker = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
      ../../modules/home/base.nix
      ./git.nix
      ./ssh.nix
    ];

    home = {
      username = "seeker";
      homeDirectory = "/home/seeker";
      stateVersion = "24.05";
      sessionPath = [ "/home/seeker/.local/bin" ];
      packages = with pkgs; [
        age
        btop
        ethtool
        fastfetch
        fd
        file
        fzf
        iftop
        iotop
        iperf3
        jq
        lm_sensors
        lsof
        mtr
        ncdu
        nix-output-monitor
        nmap
        pciutils
        ripgrep
        rsync
        sops
        sysstat
        tree
        unzip
        usbutils
        xz
        zip
        zstd
      ];
    };

    programs = {
      bash.enable = true;
      direnv.enable = true;
      fish.enable = true;
      home-manager.enable = true;
      ssh.settings."vps.seekerer.com" = {
        IdentityFile = [ "/home/seeker/.ssh/id_admin" ];
        IdentitiesOnly = true;
      };
      tmux.enable = true;
      yazi.enable = true;
      zellij.enable = true;
    };

    sops = {
      age.keyFile = "/home/seeker/.config/sops/age/keys.txt";
      secrets = {
        "ssh-admin-private" = {
          sopsFile = sshKeys.files.admin;
          key = "private_key";
          path = "/home/seeker/.ssh/id_admin";
          mode = "0600";
        };
        "ssh-admin-public" = {
          sopsFile = sshKeys.files.admin;
          key = "public_key_unencrypted";
          path = "/home/seeker/.ssh/id_admin.pub";
          mode = "0644";
        };
      };
    };
  };
}
