{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = lib.attrByPath [
    "machine"
    "btrfs"
    "impermanence"
  ] { } osConfig;
  impermanenceEnabled = lib.attrByPath [
    "machine"
    "impermanence"
    "enable"
  ] false osConfig;
in
{
  config = lib.mkIf impermanenceEnabled {
    home.persistence."${cfg.persistdir}" = {
      # allowOther = true;
      directories = [
        "Downloads"
        "Documents"
        "Pictures"
        "Videos"
        ".ssh"
        ".gnupg"
        ".factorio"
      ];
      files = [
        ".gtkwaverc"
      ];
    };
    # must enable aloneside allowOther
    # programs.fuse.userAllowOther = true;
  };
}
