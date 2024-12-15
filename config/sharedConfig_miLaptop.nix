##########################################################
#
#  The global config for all .nix files for miLaptop
#  (passed to specialArgs in nixosSystem)
#  specialArgs = {inherit sharedConfig;}
#
# To use the config,first import sharedConfig:
# { sharedConfig, ... }:
# then use sharedConfig.XXX
#
##########################################################
{
  sharedConfig = {
    machine = "miLaptop";
    desktop_environment = "dwm";
    software_package = "full";
  };
}
