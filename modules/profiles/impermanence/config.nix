{ lib, ... }:
with lib;
{
  options.seeker.btrfs.impermanence = {
    enable = mkEnableOption "Btrfs Impermanence setup";

    device = mkOption {
      type = types.str;
      description = "The path to the physical disk device.";
    };

    luksName = mkOption {
      type = types.str;
      default = "crypted";
    };

    retentionDays = mkOption {
      type = types.int;
      default = 30;
      description = "How many days to keep old root subvolumes.";
    };

    persistdir = mkOption {
      type = types.str;
      default = "/persist";
      description = "The path to the persistent directory.";
    };

    allowDiscards = mkOption {
      type = types.bool;
      default = true;
      description = "Enable TRIM support on LUKS.";
    };
  };
}
