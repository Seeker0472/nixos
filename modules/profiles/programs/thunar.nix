{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.machine.programs.thunar.enable = lib.mkEnableOption "Thunar";

  config = lib.mkIf config.machine.programs.thunar.enable {
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    programs.xfconf.enable = true;

    services.gvfs.enable = true;
    services.tumbler.enable = true; # 缩略图服务
  };
}
