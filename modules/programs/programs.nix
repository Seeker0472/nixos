{ pkgs, nur, ... }: {
  home.packages = with pkgs;[
    vscode
    # v2raya
    # v2ray
    # qv2ray
    gtkwave
    qq
    wechat-uos
    clash-verge-rev
    jetbrains.idea-ultimate
    jetbrains.clion
    jetbrains.pycharm-professional
    wpsoffice-cn
    nixpkgs-fmt
    fish
    kitty
    axel
    pkgs.nur.repos.linyinfeng.wemeet
    pkgs.nur.repos.lschuermann.vivado-2022_2
    # pkgs.nur.repos.rewine.wps
    # pkgs.nur.repos.rewine.ttf-wps-fonts
    gparted

    rocmPackages_5.llvm.clang-tools-extra #clangd

    ciscoPacketTracer8
    # virtualbox
    # wineWowPackages.stable
    # winetricks
    # wine
    # nur.repos.linyinfeng.wemeet

    networkmanagerapplet
    obs-studio
  ];

}
