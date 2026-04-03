{
  lib,
  ...
}:
let
  profileModules = [
    ./profiles/de/de_kde.nix
    ./profiles/de/hyprland/default.nix
    ./profiles/de/options.nix
    ./profiles/impermanence/btrfs.nix
    ./profiles/impermanence/config.nix
    ./profiles/programs/default.nix
    ./profiles/programs/kde-connect.nix
    ./profiles/programs/mihomo/mihomo.nix
    ./profiles/programs/nixvim/default.nix
    ./profiles/programs/steam.nix
    ./profiles/programs/tailscale.nix
    ./profiles/programs/thunar.nix
    ./profiles/programs/winapps.nix
    ./profiles/programs/zed.nix
    ./profiles/secrets/gpg.nix
    ./profiles/secrets/nix_githubtoken.nix
    ./profiles/secrets/sops.nix
    ./profiles/secrets/webdav.nix
    ./profiles/shell/default.nix
    ./profiles/system/core/common.nix
    ./profiles/system/core/networking.nix
    ./profiles/system/core/openssh.nix
    ./profiles/system/core/virtualization.nix
    ./profiles/system/dev/default.nix
    ./profiles/system/hardware/intel.nix
    ./profiles/system/hardware/laptop.nix
    ./profiles/system/hardware/user-accounts.nix
    ./profiles/system/hardware/users.nix
  ];
in
{
  imports = profileModules;

  # Some general options here,
  # Detailed options should resides in ./profiles,and /users or /hosts enables them.
  options.machine = {
    type = lib.mkOption {
      type = lib.types.enum [
        "others"
        "container"
        "laptop"
        "desktop"
        "server"
      ];
      default = "others";
      description = "the basic type of this machine";
    };
    mainUser = lib.mkOption {
      type = lib.types.str;
      default = "seeker";
      description = "Main user of this machine";
    };
    cpu = lib.mkOption {
      type = lib.types.enum [
        "others"
        "intel"
        "amd"
      ];
      default = "others";
      description = "the cpu of this machine";
    };
    impermanence.enable = lib.mkEnableOption "impermanence";
    features = {
      launcher.aloha = {
        enable = lib.mkEnableOption "Aloha launcher integration";
        menuCommand = lib.mkOption {
          type = lib.types.str;
          default = ''notify-send "TODO"'';
          description = "Launcher command wired to the shared $menu variable.";
        };
        commandsCommand = lib.mkOption {
          type = lib.types.str;
          default = ''notify-send "TODO"'';
          description = "Command palette launcher for Hyprland keybinds.";
        };
        powerCommand = lib.mkOption {
          type = lib.types.str;
          default = ''notify-send "TODO"'';
          description = "Power palette launcher for Hyprland keybinds.";
        };
        windowRules = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Extra Hyprland window rules for the Aloha launcher.";
        };
      };
      lidSwitch = {
        enable = lib.mkEnableOption "Hyprland lid switch commands";
        switchOffCommand = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Command used for the switch:off lid event.";
        };
        switchOnCommand = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Command used for the switch:on lid event.";
        };
      };
    };
  };
}
