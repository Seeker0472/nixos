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
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = with pkgs; [
      codex
      ripgrep
    ];
    home.persistence."${cfg.persistdir}" = {
      # allowOther = true;
      directories = [
        "Downloads"
        "Documents"
        "Pictures"
        "Videos"
        ".ssh"
        ".gnupg"
        #TODO:move it out!
        ".vscode"
        ".config/Code"
        ".codex"
        ".gemini"
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
