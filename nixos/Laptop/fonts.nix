{ config, lib, pkgs, modulesPath, ... }:
let
  materal-disign-icons-locked = (pkgs.material-design-icons.overrideAttrs (oldAttrs: rec {
    version = "7.4.47";

    src = pkgs.fetchFromGitHub {
      owner = "Templarian";
      repo = "MaterialDesign-Webfont";
      rev = "v${version}";
      hash = "sha256-7t3i3nPJZ/tRslLBfY+9kXH8TR145GC2hPFYJeMHRL8=";
      sparseCheckout = [ "fonts" ];
    };

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/fonts/"{eot,truetype,woff,woff2}
      cp fonts/*.eot "$out/share/fonts/eot/"
      cp fonts/*.ttf "$out/share/fonts/truetype/"
      cp fonts/*.woff "$out/share/fonts/woff/"
      cp fonts/*.woff2 "$out/share/fonts/woff2/"

      runHook postInstall
    '';

    passthru.updateScript = pkgs.nix-update-script { };

    patches = [ ]; # 禁用所有补丁
  }));
in
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
      # material-design-icons
      materal-disign-icons-locked
      joypixels
      wqy_microhei
    ];
  };

}
