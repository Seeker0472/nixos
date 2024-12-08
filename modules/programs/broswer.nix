{ pkgs, nur, ... }: {
  home.packages = with pkgs;[ 
    #broswer
    google-chrome
    microsoft-edge
    chromium
  ];
}