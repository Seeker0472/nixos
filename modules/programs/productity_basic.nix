{ pkgs, nur, ... }: {
  home.packages = with pkgs;[
    # productivity
    wpsoffice-cn
    obsidian
    pandoc #文档
  ];
}