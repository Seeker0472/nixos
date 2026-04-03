{ lib, ... }:
with lib;
{
  options.machine.btrfs.impermanence = {
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

    resumeDevice = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Resume device to configure for hibernation, if any.";
    };

    resumeOffset = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Swap file resume offset to append to kernel params, if any.";
    };

    luksKeyFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Optional bootstrap key file for Disko-managed LUKS.";
    };
  };
}
