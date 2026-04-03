{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  impermanenceEnabled = lib.attrByPath [
    "machine"
    "impermanence"
    "enable"
  ] false osConfig;
  persistDir = lib.attrByPath [
    "machine"
    "btrfs"
    "impermanence"
    "persistdir"
  ] null osConfig;
in
{
  options.homeProfiles.apps.vscode.enable = lib.mkEnableOption "VSCode";
  config = lib.mkMerge [
    (lib.mkIf config.homeProfiles.apps.vscode.enable {
      home.packages = [ pkgs.vscode ];
      wayland.windowManager.hyprland.settings = {
        bind = [ "$mainMod, V, workspace, 201" ];
        workspace = [
          "201, defaultName:󰨞, on-created-empty: [ ] code"
        ];
      };
    })
    (lib.mkIf (config.homeProfiles.apps.vscode.enable && impermanenceEnabled && persistDir != null) {
      home.persistence."${persistDir}".directories = [
        ".vscode"
        ".config/Code"
      ];
    })
  ];

}
