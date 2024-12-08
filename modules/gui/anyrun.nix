{ pkgs, anyrun, ... }: {
  # imports = [
  #    anyrun.homeManagerModules.anyrun # Import the anyrun home-manager module
  # ];
  # programs.anyrun = {
  #   enable = true;
  #   config = {
  #     plugins = with anyrun.packages.${pkgs.system}; [
  #       applications
  #       # randr # Rotate and resize monitor config Hyperland only
  #       # rink
  #       shell
  #       symbols
  #       translate
  #     ];

  #     width.fraction = 0.3;
  #     y.absolute = 15;
  #     hidePluginInfo = true;
  #     closeOnClick = true;
  #     layer = "overlay";
  #   };
  #   # extraCss =

  #   #     programs.anyrun.extraConfigFiles."plugin-name.ron".text = '''
  #   #       Config(
  #   #         some_option: true,
  #   #       )
  #   #     '''
  # };
}
