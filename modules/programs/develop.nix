{ pkgs, nur, ... }: {
  home.packages = with pkgs;[
    jetbrains.idea-ultimate
    # jetbrains.clion
    # jetbrains.pycharm-professional

    pkgs.nur.repos.lschuermann.vivado-2022_2
    # ciscoPacketTracer8
  ];
}