{ lib, ... }:
{
  # Profile implementations live in explicit bundles under ./bundles.
  # Keeping this module options-only prevents every host from inheriting
  # desktop, development, and secret services by accident.
  options.machine = {
    type = lib.mkOption {
      type = lib.types.enum [
        "others"
        "laptop"
        "desktop"
        "server"
      ];
      default = "others";
      description = "The basic type of this machine";
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
      description = "The CPU of this machine";
    };
    impermanence.enable = lib.mkEnableOption "impermanence";
  };
}
