{ hostFile, extraModules ? [ ] }:
let
  host = import hostFile;
in
{
  imports = extraModules;

  networking.hostName = host.hostName;
  system.stateVersion = host.stateVersion;
  machine = host.machine;
}
