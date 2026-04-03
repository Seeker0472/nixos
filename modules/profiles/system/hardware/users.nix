{ config, lib, ... }:
let
  cfg = config.machine.users;
  userSubmodule =
    {
      name,
      ...
    }:
    {
      options = {
        enable = lib.mkEnableOption "${name} user";
        uid = lib.mkOption {
          type = lib.types.int;
          default =
            if name == "seeker" then
              1000
            else if name == "hagrid" then
              1001
            else
              1000;
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
  options.machine.users = {
    seeker = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable seeker user";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 1000;
        description = "UID for seeker user";
      };
    };
    hagrid = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable hagrid user";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 1001;
        description = "UID for hagrid user";
      };
    };
  };

  config = lib.mkMerge [
    {
      users.mutableUsers = lib.mkDefault false;
      users.users.root.hashedPassword = "$6$Ew9uzvrMkL/nHax2$hovmxM9ttsZmDNkrh3Ah1S8FATYv5UDJp.5rwrWTFnZQBdifPpKD6inbv/QIA0ttXi07uaWOJtaFcGkuK/mPz.";
    }
    (lib.mkIf cfg.seeker.enable {
      users.users.seeker = {
        isNormalUser = true;
        description = "seeker";

        uid = cfg.seeker.uid;

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
    })
    (lib.mkIf cfg.hagrid.enable {
      users.users.hagrid = {
        isNormalUser = true;
        description = "hagrid";

        uid = cfg.hagrid.uid;

        extraGroups = [
          "networkmanager"
          "wheel"
          "disk"
        ];

        hashedPassword = "$6$74rDAv.XBN1ij1Im$9jaF6TIqkwT1M6BTD2C8Q.yETKyAlz39gzwBrvSNDwCI47CcJIYu3QVNa8L/H1HPJQusoI3eArN99gAiasRCz.";
      };
    })
  ];
}
