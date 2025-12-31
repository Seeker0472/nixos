{
  pkgs,
  nur,
  nixpkgs-dev,
  ...
}: {
  home.packages = with pkgs; [
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
