{ config, lib, ... }:
let
  enabledUsers = lib.filterAttrs (_: userCfg: userCfg.enable) config.machine.users;
in
{
  config = {
    users.mutableUsers = lib.mkDefault false;
    users.users = {
      root.hashedPassword = "$6$Ew9uzvrMkL/nHax2$hovmxM9ttsZmDNkrh3Ah1S8FATYv5UDJp.5rwrWTFnZQBdifPpKD6inbv/QIA0ttXi07uaWOJtaFcGkuK/mPz.";
    }
    // lib.mapAttrs (_: userCfg: {
      isNormalUser = true;
      description = userCfg.description;
      uid = userCfg.uid;
      extraGroups = userCfg.extraGroups;
      hashedPassword = userCfg.hashedPassword;
      openssh.authorizedKeys.keys = userCfg.authorizedKeys;
    }) enabledUsers;
  };
}
