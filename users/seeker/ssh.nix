_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "yes";
        Compression = false;
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
      "github.com" = {
        HostName = "ssh.github.com";
        Port = 443;
        User = "git";
      };
      ecos = {
        HostName = "10.19.20.2";
        User = "seeker4721";
      };
    };
  };
}
