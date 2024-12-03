{ pkgs, ... }: {
programs.fish = {
    enable = true;
    # TODO:添加OMF
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set theme_color_scheme zenburn
      set theme_date_format +"%b/%e|%a %H:%M.%S"
      function fish_greeting; end
    '';
    # plugins = [
    #   # Enable a plugin (here grc for colorized command output) from nixpkgs
    #   { name = "grc"; src = pkgs.fishPlugins.grc.src; }
    #   # Manually packaging and enable a plugin
    #   {
    #     name = "z";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "jethrokuan";
    #       repo = "z";
    #       rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
    #       sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
    #     };
    #   }
    # ];
  };
  home.packages = with pkgs;[
    # oh-my-fish
    subversion
  ];
}