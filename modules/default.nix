{ lib, ... }: {
  imports = [ ./profiles ];

  # Some general options here,
  # Detailed options should resides in ./profiles,and /users or /hosts enables them.
  options.my.type = lib.mkOption {
    type = lib.types.enum [ "laptop" "desktop" "server" ];
    description = "the basic type of this machine";
  };
  mainUser = lib.mkOption {
    type = lib.types.str;
    default = "seeker";
    description = "Main user of this machine";
  };

}
