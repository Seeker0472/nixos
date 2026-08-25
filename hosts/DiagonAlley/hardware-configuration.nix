{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # WSL/Windows inspection: Gigabyte B650M AORUS ELITE AX ICE, Ryzen 9 9950X,
  # RTX 5070, Intel AX210 Wi-Fi, Realtek 2.5GbE, and three Samsung NVMe disks.
  # A Live ISO should regenerate this file before installation.
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = true;

  # Root, /nix, /persist, swap and /boot are declared by disk.nix through the
  # shared Btrfs impermanence/Disko module. The target disk there is a
  # deliberate placeholder until the Live ISO exposes stable by-id paths.

  hardware.graphics.enable = true;
  hardware.nvidia = {
    # RTX 5070 (Blackwell) uses the open NVIDIA kernel module.
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      kdePackages.fcitx5-chinese-addons
      fcitx5-gtk
    ];
  };
}
