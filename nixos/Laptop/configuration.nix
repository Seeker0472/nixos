# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, modulesPath, ... }:

{
  #HardWare AccelerationConfig
  #https://nixos.wiki/wiki/Accelerated_Video_Playback
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics = { # hardware.graphics on unstable
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver
  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [ intel-vaapi-driver ];


  #Make Windows Happy
  time.hardwareClockInLocalTime = true;

  # time zone.
  time.timeZone = "Asia/Hong_Kong";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_HK.UTF-8";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  # sound.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  #i2c need user in group?
  hardware.i2c.enable = true;

  #mirror and allfirmware
  hardware.enableAllFirmware = true;
  nix.settings.substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #  jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.seeker = {
    isNormalUser = true;
    description = "seeker";
    extraGroups = [ "networkmanager" "wheel" "audio" "i2c" "docker" ];
  };
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];


  #   ## Added-User
  #   users.users.seekerRemote = {
  #     isNormalUser = true;
  #     description = "ryan";
  #     extraGroups = [ "networkmanager" "wheel" ];
  # #     openssh.authorizedKeys.keys = [
  # #         # replace with your own public key
  # #         "ssh-ed25519 <some-public-key> ryan@ryan-pc"
  # #     ];
  #     packages = with pkgs; [
  #       firefox
  #     #  thunderbird
  #     ];
  #   };

  # 将默认编辑器设置为 vim
  environment.variables.EDITOR = "vim";
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
