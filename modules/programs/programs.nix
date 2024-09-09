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
    wpsoffice-cn
    nixpkgs-fmt
    fish

    # nur.repos.linyinfeng.wemeet

  ];

}
