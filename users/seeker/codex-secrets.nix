{ config, lib, ... }:
lib.mkIf config.programs.codex.enable {
  sops.secrets."codex-auth" = {
    sopsFile = ./codex-auth.secrets.json;
    format = "json";
    # Empty key means sops-nix decrypts the complete auth.json document.
    key = "";
    path = "${config.home.homeDirectory}/.codex/auth.json";
    mode = "0600";
  };
}
