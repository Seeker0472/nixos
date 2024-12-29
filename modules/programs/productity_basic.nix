{ pkgs, nur, sharedConfig, ... }: {
  home.packages = with pkgs;[
    # productivity
    pandoc #文档
  ] ++ (if sharedConfig.software_package == "cli" then [ ] else [
    wpsoffice-cn
    obsidian
  ]);

}
