{lib, ...}: {
  imports = [./profiles];

  # Some general options here,
  # Detailed options should resides in ./profiles,and /users or /hosts enables them.
  options.seeker = {
    machine_type = lib.mkOption {
      type =
        lib.types.enum ["others" "container" "laptop" "desktop" "server"];
      default = "others";
      description = "the basic type of this machine";
    };
    mainUser = lib.mkOption {
      type = lib.types.str;
      default = "seeker";
      description = "Main user of this machine";
    };
    cpu = lib.mkOption {
      type = lib.types.enum ["others" "intel" "amd"];
      default = "others";
      description = "the cpu of this machine";
    };
  };
}
