{ config, lib, ... }:
let
  enabledUsers = lib.filterAttrs (_: userCfg: userCfg.enable) config.machine.users;
  enabledUserNames = builtins.attrNames enabledUsers;
  missingUidUsers = builtins.filter (name: enabledUsers.${name}.uid == null) enabledUserNames;
  missingPasswordUsers = builtins.filter (
    name: enabledUsers.${name}.hashedPassword == null
  ) enabledUserNames;
  enabledUids = map (name: enabledUsers.${name}.uid) enabledUserNames;
in
{
  config = {
    assertions = [
      {
        assertion = missingUidUsers == [ ];
        message =
          "Enabled machine.users entries must define a unique uid when no built-in default exists: "
          + lib.concatStringsSep ", " missingUidUsers;
      }
      {
        assertion = builtins.length enabledUids == builtins.length (lib.unique enabledUids);
        message = "Enabled machine.users entries must use unique UIDs.";
      }
      {
        assertion = missingPasswordUsers == [ ];
        message =
          "Enabled machine.users entries must define a hashedPassword when no built-in default exists: "
          + lib.concatStringsSep ", " missingPasswordUsers;
      }
    ];
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
