{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.seeker.home.vscode.enable = lib.mkEnableOption "VSCode";
  config = lib.mkMerge [
    (lib.mkIf config.seeker.home.vscode.enable {
      home.packages = [ pkgs.vscode ];
      wayland.windowManager.hyprland.settings = {
        bind = [ "$mainMod, V, workspace, 201" ];
        workspace = [
          "201, defaultName:󰨞, on-created-empty: [ ] code"
        ];
      };

    })
  ];

}
