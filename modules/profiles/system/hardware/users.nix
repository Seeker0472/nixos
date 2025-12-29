{config, ...}: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.seeker = {
    isNormalUser = true;
    description = "seeker";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "i2c"
      "docker"
      "dialout"
      "disk"
      "input"
      "video"
    ];
  };
}
