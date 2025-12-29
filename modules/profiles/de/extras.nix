{
  config,
  pkgs,
  ...
}: {
  #hardware!
  environment.systemPackages = with pkgs; [
    pulseaudioFull
  ];

  # Thunar support
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
}
