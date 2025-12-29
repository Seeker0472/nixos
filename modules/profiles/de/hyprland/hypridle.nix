{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
            unlock_cmd = ''${pkgs.libnotify}/bin/notify-send "unlock!"'';
            before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
            ignore_dbus_inhibit = false;
            ignore_systemd_inhibit = false;
          };

          listener = [
            {
              timeout = 240;
              on-timeout = ''
                ${pkgs.acpi}/bin/acpi -a | ${pkgs.gnugrep}/bin/grep -q "on-line" && ${pkgs.libnotify}/bin/notify-send "Zzz"'';
            }
            {
              timeout = 300;
              on-timeout = ''
                ${pkgs.acpi}/bin/acpi -a | ${pkgs.gnugrep}/bin/grep -q "on-line" && ${pkgs.systemd}/bin/loginctl lock-session'';
            }
            {
              timeout = 600;
              on-timeout = ''
                ${pkgs.acpi}/bin/acpi -a | ${pkgs.gnugrep}/bin/grep -q "on-line" && ${pkgs.systemd}/bin/systemctl hibernate'';
            }
          ];
        };
      };
    }
  ];
}
