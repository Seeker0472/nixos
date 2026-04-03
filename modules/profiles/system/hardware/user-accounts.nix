{ config, lib, ... }:
let
  enabledUsers = lib.filterAttrs (_: userCfg: userCfg.enable) config.machine.users;
  enabledUserNames = builtins.attrNames enabledUsers;
  mkMissingFieldAssertion = field: messagePrefix: {
    assertion = builtins.filter (name: enabledUsers.${name}.${field} == null) enabledUserNames == [ ];
    message =
      messagePrefix
      + lib.concatStringsSep ", " (
        builtins.filter (name: enabledUsers.${name}.${field} == null) enabledUserNames
      );
  };
  missingUidUsers = builtins.filter (name: enabledUsers.${name}.uid == null) enabledUserNames;
  missingPasswordUsers = builtins.filter (
    name: enabledUsers.${name}.hashedPassword == null
  ) enabledUserNames;
  enabledUids = map (name: enabledUsers.${name}.uid) enabledUserNames;
in
{
  config = {
    assertions = [
      (mkMissingFieldAssertion "uid" "Enabled machine.users entries must define a unique uid when no built-in default exists: ")
      {
        assertion = builtins.length enabledUids == builtins.length (lib.unique enabledUids);
        message = "Enabled machine.users entries must use unique UIDs.";
      }
      (mkMissingFieldAssertion "hashedPassword" "Enabled machine.users entries must define a hashedPassword when no built-in default exists: ")
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
