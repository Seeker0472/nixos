{
  config,
  lib,
  pkgs,
  ...
}:
let
  stateDirectory = "diagonalley-fan-control";
  runtimeDirectory = "diagonalley-fan-control";
  stateFile = "/var/lib/${stateDirectory}/state.json";
  configFile = "/run/${runtimeDirectory}/fancontrol.conf";
  lockFile = "/run/${stateDirectory}.lock";

  backend = pkgs.writeShellApplication {
    name = "diagonalley-fan-control-backend";
    runtimeInputs = [
      pkgs.lm_sensors
      pkgs.python3
      pkgs.systemd
    ];
    text = ''
      export FAN_CONTROL_SYSFS_ROOT=/sys/class/hwmon
      export FAN_CONTROL_SYS_ROOT=/sys
      export FAN_CONTROL_STATE_FILE=${stateFile}
      export FAN_CONTROL_CONFIG_FILE=${configFile}
      export FAN_CONTROL_LOCK_FILE=${lockFile}
      export FAN_CONTROL_SYSTEMCTL=${pkgs.systemd}/bin/systemctl
      export FAN_CONTROL_FANCONTROL=${lib.getExe' pkgs.lm_sensors "fancontrol"}
      exec ${lib.getExe pkgs.python3} ${./controller.py} "$@"
    '';
  };

  applyHelper = pkgs.writeShellApplication {
    name = "diagonalley-fan-control-apply";
    text = ''
      if (( $# != 1 )); then
        echo "usage: diagonalley-fan-control-apply JSON_PATCH" >&2
        exit 2
      fi
      exec ${lib.getExe backend} apply-root "$1"
    '';
  };

  client = pkgs.writeShellApplication {
    name = "fan-control";
    runtimeInputs = [
      pkgs.polkit
      pkgs.python3
      pkgs.systemd
    ];
    text = ''
      export FAN_CONTROL_SYSFS_ROOT=/sys/class/hwmon
      export FAN_CONTROL_SYS_ROOT=/sys
      export FAN_CONTROL_STATE_FILE=${stateFile}
      export FAN_CONTROL_CONFIG_FILE=${configFile}
      export FAN_CONTROL_LOCK_FILE=${lockFile}
      export FAN_CONTROL_SYSTEMCTL=${pkgs.systemd}/bin/systemctl
      export FAN_CONTROL_PKEXEC=${config.security.wrapperDir}/pkexec
      export FAN_CONTROL_HELPER=${lib.getExe applyHelper}
      export FAN_CONTROL_FANCONTROL=${lib.getExe' pkgs.lm_sensors "fancontrol"}
      exec ${lib.getExe pkgs.python3} ${./controller.py} "$@"
    '';
  };
in
{
  hardware.fancontrol = {
    enable = true;
    # The service override below generates the active configuration at runtime.
    config = "# Managed by diagonalley-fan-control";
  };

  systemd.services.fancontrol = {
    description = lib.mkForce "Temperature-protected fan control for DiagonAlley";
    after = [ "systemd-tmpfiles-setup.service" ];
    serviceConfig = {
      ExecStartPre = "${lib.getExe backend} prepare";
      ExecStart = lib.mkForce "${lib.getExe backend} run";
      ExecStopPost = "${lib.getExe backend} restore-bios";
      StateDirectory = stateDirectory;
      StateDirectoryMode = "0755";
      RuntimeDirectory = runtimeDirectory;
      RuntimeDirectoryMode = "0755";
      Restart = "on-failure";
      RestartSec = 2;
      TimeoutStopSec = 10;
      UMask = "0022";
    };
  };

  security.polkit = {
    enable = true;
    enablePkexecWrapper = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        // The helper accepts only validated fan patches, so this grant is
        // limited to the machine user and this exact executable.
        if (action.id == "org.freedesktop.policykit.exec" &&
            action.lookup("program") == "${lib.getExe applyHelper}" &&
            subject.user == "${config.machine.mainUser}") {
          return polkit.Result.YES;
        }
      });
    '';
  };

  environment.persistence."${config.machine.btrfs.impermanence.persistdir}".directories = [
    "/var/lib/${stateDirectory}"
  ];

  environment.systemPackages = [ client ];

  home-manager.users.${config.machine.mainUser}.programs.niri-shell.fanControl = {
    enable = true;
    package = client;
  };
}
