{ pkgs, nur, sharedConfig, ... }: {
  home.packages = with pkgs;
    [ ] ++ (if builtins.elem "gui" sharedConfig.software_package then [
      #broswer
      google-chrome
      #    microsoft-edge
      chromium
    ] else
      [ ]);
}
