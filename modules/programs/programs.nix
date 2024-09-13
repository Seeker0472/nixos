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
    gparted

    ciscoPacketTracer8
    # virtualbox
    # wineWowPackages.stable
    # winetricks
    # wine
    # nur.repos.linyinfeng.wemeet

  ];

}
