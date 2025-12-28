{ pkgs,  ... }: {
  imports = [ ./tools.nix ./bash.nix ./fish.nix ./tmux ./map.nix ] ++ [./kitty.nix];
  #  ++ (if builtins.elem "gui" sharedConfig.software_package then
  #    [ ./kitty.nix ]
  #  else
  #    [ ]);
}
