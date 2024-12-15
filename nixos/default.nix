{ pkgs, nur, sharedConfig, ... }: {
  imports = [
    ./common
  ]
  ++ (if sharedConfig.machine == "miLaptop" then [ ./Laptop ] else [ ])
  ++ (if sharedConfig.machine == "LTG" then [ ./LTG ] else [ ]);

  # assert sharedConfig.machine == "miLaptop" || sharedConfig.machine == "LTG";
}

