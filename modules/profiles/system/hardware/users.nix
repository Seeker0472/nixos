{ config, lib, ... }:
let
  cfg = config.machine.users;
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

        #TODO:maybe add options here
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

        # TODO
        # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
      };
    })
    (lib.mkIf cfg.hagrid.enable {
      users.users.hagrid = {
        isNormalUser = true;
        description = "hagrid";

        uid = cfg.hagrid.uid;

        #TODO:maybe add options here
        extraGroups = [
          "networkmanager"
          "wheel"
          "disk"
        ];

        hashedPassword = "$6$74rDAv.XBN1ij1Im$9jaF6TIqkwT1M6BTD2C8Q.yETKyAlz39gzwBrvSNDwCI47CcJIYu3QVNa8L/H1HPJQusoI3eArN99gAiasRCz.";

        # TODO
        # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
      };
    })
  ];
}
