{ config, lib, pkgs, modulesPath, ... }: {
  nixpkgs.config.joypixels.acceptLicense = true;
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      wqy_microhei
      sarasa-gothic # 更纱黑体
      # jetbrains-mono
      maple-mono.NF-CN

      # nerd-fonts.fira-code
      # nerd-fonts.jetbrains-mono
      # nerd-fonts.symbols-only
      joypixels
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "Noto Sans CJK SC" ];
        serif = [ "Noto Serif CJK SC" ];
        monospace = [ "Maple Mono NF CN" ];
        emoji = [ "JoyPixels" ];
      };
    };
  };

}
