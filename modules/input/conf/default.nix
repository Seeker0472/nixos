{ pkgs, ... }: {
  home.file."./.config/fcitx5/conf/classicui.conf".source = ./classicui.conf;
  # home.file."./.config/fcitx5/conf/notifications.conf".source = ./notifications.conf;
}