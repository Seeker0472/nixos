{ pkgs, nixpkgs-stable, nur, winapps, ... }: {
  home.packages = with pkgs;[
    # dialog
    # freerdp3
    winapps.packages.${system}.winapps
    winapps.packages.${system}.winapps-launcher # optional
  ];
  # home.file.".local/bin/winapps".source = "${winapps}/bin/winapps";
}
