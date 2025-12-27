{ pkgs, nur,  ... }: {
  #imports = [
  #  # ./common
  #] ++ (if sharedConfig.machine == "miPad" then [ ] else [ ./common ])
  #  ++ (if sharedConfig.machine == "miLaptop" then [ ./Laptop ] else [ ])
  #  ++ (if sharedConfig.machine == "LTG" then [ ./LTG ] else [ ])
  #  ++ (if sharedConfig.machine == "miPad" then [ ./miPad ] else [ ]);
  imports =[ ./Laptop ./common ];

  # assert sharedConfig.machine == "miLaptop" || sharedConfig.machine == "LTG";
}
