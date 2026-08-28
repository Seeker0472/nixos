{
  config,
  pkgs,
  ...
}:
let
  version = "unstable-2026-08-25";

  # TODO: Remove this override after the it87 update is merged into Nixpkgs
  # and flake.lock points to a Nixpkgs revision containing that update.
  it87 = config.boot.kernelPackages.it87.overrideAttrs {
    inherit version;
    name = "it87-${version}-${config.boot.kernelPackages.kernel.version}";
    src = pkgs.fetchFromGitHub {
      owner = "frankcrawford";
      repo = "it87";
      rev = "c567739c639533177abd66894a6a8d561337285f";
      hash = "sha256-MvaqqiwUA15lqJXgRapABqSUrOfeP9bkEdb7IEZuUOE=";
    };
  };
in
{
  boot.extraModulePackages = [ it87 ];
  boot.kernelModules = [ "it87" ];
}
