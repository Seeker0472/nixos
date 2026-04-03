{ lib, ... }:
let
  userSubmodule =
    { name, ... }:
    {
      options = {
        enable = lib.mkEnableOption "${name} user";
        uid = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default =
            if name == "seeker" then
              1000
            else if name == "hagrid" then
              1001
            else
              null;
          description = "UID for ${name}";
        };
        description = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "User description for ${name}";
        };
        extraGroups = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default =
            if name == "seeker" then
              [
                "networkmanager"
                "wheel"
                "docker"
                "audio"
                "video"
                "input"
                "disk"
                "dialout"
                "i2c"
              ]
            else if name == "hagrid" then
              [
                "networkmanager"
                "wheel"
                "disk"
              ]
            else
              [ ];
          description = "Extra groups for ${name}";
        };
        hashedPassword = lib.mkOption {
          type = lib.types.str;
          default =
            if name == "seeker" then
              "$6$3nvVWJDicXst2Wtt$EdriZ4ylx/y7yEVEINT3k3JdrjF1MQG6ysITGmTR5pDiiceX2t8RjJiDutZyez2TQ/WeX1BB34/hMwF.s1m4L."
            else if name == "hagrid" then
              "$6$74rDAv.XBN1ij1Im$9jaF6TIqkwT1M6BTD2C8Q.yETKyAlz39gzwBrvSNDwCI47CcJIYu3QVNa8L/H1HPJQusoI3eArN99gAiasRCz."
            else
              "";
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
