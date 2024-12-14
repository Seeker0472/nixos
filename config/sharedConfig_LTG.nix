##########################################################
#
#  The global config for all .nix files for LTG
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
    # desktop_environment = "dwm";
  };
}