{ inputs, ... }:
let
  hmShared = import ../../outputs/common/home-manager-shared.nix { inherit inputs; };
in
{
  imports = [
    ./home-manager-base.nix
  ];

  home-manager = {
    users.seeker = {
      imports = hmShared.mkModuleList {
        extraModules = [
          ./home.nix
          ./server.nix
        ];
      };
    };
  };
}
