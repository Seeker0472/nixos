{
  pkgs,
  config,
  ...
}: {
  programs.ssh = {
    # FIXME: warring!
    # evaluation warning: seeker profile: `programs.ssh` default values will be removed in the future.
    #                 Consider setting `programs.ssh.enableDefaultConfig` to false,
    #                 and manually set the default values you want to keep at
    #                 `programs.ssh.matchBlocks."*"`.
    enable = true;
    extraConfig = ''
      IdentityFile ${config.sops.secrets."id_ed25519".path}

      Host github.com
        Hostname ssh.github.com
        Port 443
        User git
        ProxyCommand nc -X connect -x 127.0.0.1:7890 %h %p
    '';
    # identityFile = [config.sops.secrets."id_ed25519".path];
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
  programs.direnv = {
    enable = true;
    # enableBashIntegration =true;
    # enableFishIntegration = true;
    nix-direnv.enable = true;
    config = {hide_env_diff = true;};
  };

  # 通过 home.packages 安装一些常用的软件
  # 这些软件将仅在当前用户下可用，不会影响系统级别的配置
  # 所有 GUI 软件，以及与 OS 关系不大的 CLI 软件，都通过 home.packages 安装
  home.packages = with pkgs; [
    neofetch
    fastfetch

    # archives
    zip
    xz
    unzip
    p7zip

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    #TODOS
    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    jq # JSON parser
    file-rename

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    #make NVIM happy
    nodejs_22
    cargo
    zulu17
    nixpkgs-fmt

    nixd
    coursier
    jdt-language-server
    ocamlPackages.junit # ai class

    ddcutil # brightness
    ranger # fileExpo

    fzf # amazing tool to find things!
  ];
  programs.yazi = {
    enable = true;
    settings = {
      tasks = {
        micro_workers = 5;
        macro_workers = 10;
        bizarre_retry = 5;
        image_alloc = 4096;
        image_bound = [15720 8640];
      };
    };
  };
}
