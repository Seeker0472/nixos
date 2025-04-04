{ pkgs, nur, sharedConfig, ... }: {
  imports = [
    # ./common
  ] ++ (if sharedConfig.machine == "miPad" then [ ] else [ ./common ])
    ++ (if sharedConfig.machine == "miLaptop" then [ ./Laptop ] else [ ])
    ++ (if sharedConfig.machine == "LTG" then [ ./LTG ] else [ ])
    ++ (if sharedConfig.machine == "miPad" then [ ./miPad ] else [ ]);

  # assert sharedConfig.machine == "miLaptop" || sharedConfig.machine == "LTG";
}
