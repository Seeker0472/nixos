{
  pkgs,
  config,
  ...
}:
{
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

    # ----- Develop ------
    # programming/ysyx/learning
    gcc
    gdb
    gnumake
    lazygit
    #neovim & dependences
    # TODO:Neovim config using nix
    # neovim
    # lua5_1
    # luarocks
    # ripgrep
    # python312Packages.ipython #TODO:python313:nix-ondroid error
    # coursier

    clang-tools
    nixfmt-classic

    # ------ Tools ------
    axel # Console app for parallel connection
    wl-clipboard
    ncdu # ----
    sops
    age
    tty-clock

    # ------ Productivity ------
    pandoc # 文档
    ffmpeg
    marp-cli

  ];

}
