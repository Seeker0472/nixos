{
  system = "x86_64-linux";
  hostName = "miLaptop";
  stateVersion = "24.05";

  machine = {
    type = "laptop";
    cpu = "intel";
    impermanence.enable = true;

    de = {
      hyprland.enable = true;
      waybar.enable = true;
      wofi.enable = true;
      mako.enable = true;
      wpaperd.enable = true;
    };

    users = {
      seeker.enable = true;
    };

    programs = {
      kdeconnect.enable = true;
      mihomo = {
        enable = true;
        tun.enable = true;
      };
      thunar.enable = true;
      steam.enable = true;
      tailscale.enable = true;
    };

    secrets = {
      ageKeyPath = "/persist/home/seeker/age/keys";
      webdav.enable = true;
    };

    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      openFirewall = true;
    };

    features = {
      launcher.aloha = {
        enable = true;
        menuCommand = "aloha --root apps";
        commandsCommand = "aloha --root commands";
        powerCommand = "aloha --root power";
        windowRules = [
          "tag +aloha_launcher, match:initial_class ^(AlohaLauncher)$"
          "float on, match:tag aloha_launcher*"
          "center on, match:tag aloha_launcher*"
          "size (monitor_w*0.7) (monitor_h*0.6), match:tag aloha_launcher*"
        ];
      };
      lidSwitch = {
        enable = true;
        switchOffCommand = ''[ $(hyprctl monitors | grep -c "eDP-1") -ne 1 ] && hyprctl keyword monitor eDP-1,2560x1600@120.0,0x237,1.33'';
        switchOnCommand = ''[ $(hyprctl monitors | grep -c "ID") -ne 1 ] && hyprctl keyword monitor eDP-1,disable'';
      };
    };

    virtualization = {
      docker.enable = true;
      virtualbox.enable = true;
    };
  };

  standalone.extraConfig = {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
    };
  };
}
