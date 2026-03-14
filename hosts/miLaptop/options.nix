{ ... }:
let
  host = import ./home.nix;
in
{
  config.machine = host.machine;
}
