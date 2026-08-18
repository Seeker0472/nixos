{
  lib,
  osConfig,
  ...
}:
let
  kdeconnectEnabled = lib.attrByPath [ "machine" "programs" "kdeconnect" "enable" ] false osConfig;
in
{
  config = lib.mkIf kdeconnectEnabled {
    services.kdeconnect.enable = true;
  };
}
