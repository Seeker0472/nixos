########################################
##  THIS is an old file that are not used anymore!
#########################################

## { pkgs, nur, sharedConfig, ... }: {
##   imports = [
##   ] ++ (if ((builtins.elem "develop" sharedConfig.software_package) || (builtins.elem "develop_full" sharedConfig.software_package)) then [
##     ./develop.nix
##     # BTW,don't think it's a good idea for nix to manage vscode settings
##     # ./vscode.nix
##   ] else [ ]);
##   }
