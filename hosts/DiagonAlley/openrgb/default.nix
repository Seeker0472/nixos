{
  lib,
  pkgs,
  ...
}:
let
  effectsProfile = "spectrum-cycle.json";
  openrgb = pkgs.openrgb.withPlugins [ pkgs.openrgb-plugin-effects ];
  prepareEffectsProfile = pkgs.writeShellScript "prepare-openrgb-effects-profile" ''
    runtime_config_dir="$1"
    ${pkgs.coreutils}/bin/install -D -m 0644 \
      ${./spectrum-cycle.json} \
      "$runtime_config_dir/plugins/settings/effect-profiles/${effectsProfile}"
  '';
in
{
  # Gigabyte's ACPI tables reserve the AMD SMBus I/O range, preventing
  # i2c-piix4 from binding and OpenRGB from detecting RGB DIMMs.
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = openrgb;
    startupProfile = "${./default.orp}";
  };

  # OpenRGB stores resizable zone lengths separately from lighting profiles.
  # Seed writable runtime state from the declarative profile on each start.
  systemd.services.openrgb.preStart = ''
    ${pkgs.coreutils}/bin/install -m 0644 \
      ${./sizes.ors} \
      /var/lib/OpenRGB/sizes.ors
  '';

  home-manager.users.seeker = {
    systemd.user.services.openrgb-effects = {
      Unit = {
        Description = "Synchronized OpenRGB effects";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Environment = "OPENRGB_EFFECTS_PLUGIN_STARTUP_PROFILE=${effectsProfile}";
        RuntimeDirectory = "openrgb-effects";
        RuntimeDirectoryMode = "0700";
        ExecStartPre = "${prepareEffectsProfile} %t/openrgb-effects";
        ExecStart = lib.escapeShellArgs [
          (lib.getExe openrgb)
          "--noautoconnect"
          "--client"
          "127.0.0.1"
          "--nodetect"
          "--startminimized"
          "--config"
          "%t/openrgb-effects"
        ];
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
