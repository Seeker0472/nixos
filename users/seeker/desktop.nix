{ pkgs, ... }:
{
  imports = [
    ./home.nix
    ./xdg_default.nix
    ../../modules/home/desktop.nix
  ];

  home.packages =
    (import ./packages/media.nix { inherit pkgs; })
    ++ (import ./packages/office.nix { inherit pkgs; })
    ++ (with pkgs; [
      netease-cloud-music-gtk
      obsidian
      qq
      vscode
      zotero
    ]);

  programs = {
    kitty.enable = true;
    zed-editor.enable = true;
    zen-browser.enable = true;
  };
}
