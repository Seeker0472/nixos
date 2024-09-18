{ config, lib, pkgs, modulesPath, ... }:

{
  nixpkgs.config.joypixels.acceptLicense = true;
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      wqy_microhei
      wqy_zenhei
      sarasa-gothic #更纱黑体
      source-code-pro
      hack-font
      jetbrains-mono

      nerdfonts
      material-design-icons
      joypixels
      wqy_microhei
    ];
  };

}
