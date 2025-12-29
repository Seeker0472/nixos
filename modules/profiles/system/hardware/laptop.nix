{
  config,
  pkgs,
  ...
}: {
  services.logind.settings.Login = {
    # don't shutdown when power button is short-pressed
    HandlePowerKey = "ignore";
  };
  # Enable CUPS to print documents.
  services.printing.enable = true;
  environment.systemPackages = [pkgs.powertop];
  boot.supportedFilesystems = ["exfat"];

  #mirror and allfirmware
  hardware.enableAllFirmware = true;
  # keyd to remap keys, caps->esc
  # wiki on https://wiki.nixos.org/wiki/Keyd
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            capslock = "esc";
            esc = "esc";
          };
          otherlayer = {};
        };
        extraConfig = "";
      };
    };
  };
  #nixpkgs.config.permittedInsecurePackages = ["openssl-1.1.1w"];
  powerManagement.powertop.enable = true;
  powerManagement.enable = true;
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };
  # systemd.extraConfig
  systemd.settings.Manager = {DefaultTimeoutStopSec = "10s";};
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  nixpkgs.config.joypixels.acceptLicense = true;
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      wqy_microhei
      sarasa-gothic # 更纱黑体
      # jetbrains-mono
      maple-mono.NF-CN

      # nerd-fonts.fira-code
      # nerd-fonts.jetbrains-mono
      # nerd-fonts.symbols-only
      joypixels
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = ["Noto Sans CJK SC"];
        serif = ["Noto Serif CJK SC"];
        monospace = ["Maple Mono NF CN"];
        emoji = ["JoyPixels"];
      };
    };
  };
  #input method
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [kdePackages.fcitx5-chinese-addons fcitx5-gtk];
  };
  hardware.i2c.enable = true;
}
