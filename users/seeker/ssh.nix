{ config, ... }:
{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
        Hostname ssh.github.com
        Port 443
        User git
    '';
    # ProxyCommand nc -X connect -x 127.0.0.1:7890 %h %p
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = true;
      addKeysToAgent = "yes";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
      identityFile = [ config.sops.secrets."id_ed25519".path ];

    };
  };
  # FIXME: add more keys-GPG machine specific key
  sops.secrets."id_ed25519" = {
    sopsFile = ./ssh.secrets.yaml;
    key = "ssh_id_ed25519_private_key";
    path = "${config.home.homeDirectory}/.ssh/id_seeker";
  };
  sops.secrets."id_ed25519-public" = {
    sopsFile = ./ssh.secrets.yaml;
    key = "ssh_id_ed25519_public_key";
    path = "${config.home.homeDirectory}/.ssh/id_seeker.pub";
  };
  sops.secrets."nix_config" = {
    sopsFile = ./ssh.secrets.yaml;
    key = "nix_config";
    path = "${config.home.homeDirectory}/.config/my_nix.conf";
  };
}
