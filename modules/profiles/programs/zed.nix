{
  config,
  lib,
  pkgs,
  ...
}: let
  # HM-side confg path
  cfgPath = ["seeker" "home" "zed"];

  # get all users
  # config.home-manager.users 是一个 Attribute Set，我们需要将其转为 List
  hmUsers = lib.attrValues config.home-manager.users;

  # lib.getAttrFromPath safely read
  # check if any user enabled
  anyUserEnabled =
    lib.any
    (userConfig: lib.attrByPath (cfgPath ++ ["enable"]) false userConfig)
    hmUsers;
in {
  config = lib.mkMerge [
    {
      home-manager.sharedModules = [
        ({
          lib,
          config,
          pkgs,
          ...
        }: {
          options.seeker.home.zed.enable =
            lib.mkEnableOption "Enable zed-editor";
          config = lib.mkIf config.seeker.home.zed.enable {
            home.packages = [pkgs.zed-editor];
          };
        })
        {
          wayland.windowManager.hyprland.settings = {
            windowrulev2 = ["workspace special:zed,class:(dev.zed.Zed)"];
            workspace = ["special:zed, on-created-empty:[ ] zeditor"];
            bind = ["$mainMod,X, togglespecialworkspace,zed"];
          };
        }
      ];
    }
    (lib.mkIf anyUserEnabled {
      services.gnome.gnome-keyring.enable = true;
      # auto-decrept
      security.pam.services.login.enableGnomeKeyring = true;

      warnings = ["Auto-enabling PAM security feature because a user requested it."];
    })
  ];
}
