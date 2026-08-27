{ lib, ... }:
let
  builtInUsers = {
    seeker = {
      uid = 1000;
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "audio"
        "video"
        "input"
        "disk"
        "dialout"
        "i2c"
      ];
      hashedPassword = "$6$3nvVWJDicXst2Wtt$EdriZ4ylx/y7yEVEINT3k3JdrjF1MQG6ysITGmTR5pDiiceX2t8RjJiDutZyez2TQ/WeX1BB34/hMwF.s1m4L.";
    };
  };
  builtInDefault =
    name: field: default:
    lib.attrByPath [ name field ] default builtInUsers;
  userSubmodule =
    { name, ... }:
    {
      options = {
        enable = lib.mkEnableOption "${name} user";
        uid = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = builtInDefault name "uid" null;
          description = "UID for ${name}";
        };
        description = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "User description for ${name}";
        };
        extraGroups = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = builtInDefault name "extraGroups" [ ];
          description = "Extra groups for ${name}";
        };
        hashedPassword = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = builtInDefault name "hashedPassword" null;
          description = "Hashed password for ${name}";
        };
        authorizedKeys = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "OpenSSH authorized keys for ${name}";
        };
      };
    };
in
{
  options.machine.users = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule userSubmodule);
    default = { };
    description = "Declarative machine users keyed by username.";
  };
}
