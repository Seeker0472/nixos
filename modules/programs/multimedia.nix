{ pkgs, nur, ... }: {
  home.packages = with pkgs;[
    # multimedia
    obs-studio
    libsForQt5.kdenlive
    vlc

  ];
}