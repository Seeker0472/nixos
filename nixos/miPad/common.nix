{ pkgs, ... }: {
  environment.packages = with pkgs; [
    vim
    git
    curl
    unixtools.column # dep for omf
    openssh
  ];
  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  environment.motd = "";
  # TODO: maybe wait next release seems not supported yet
  # user.userName = "seeker";
  # user.group = "seeker";


  # terminal.font = "${pkgs.maple-mono.NF-CN}/share/fonts/truetype/MapleMono-NF-CN-Regular.ttf";
  # user.shell= "${pkgs.fish}/bin/fish";

  time.timeZone = "Asia/Hong_Kong";
}
