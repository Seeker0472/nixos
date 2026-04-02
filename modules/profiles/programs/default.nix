{
  ...
}:
let
  homeProfiles = [
    ./home/bash.nix
    ./home/claude/default.nix
    ./home/direnv.nix
    ./home/fish.nix
    ./home/geminicli/default.nix
    ./home/kitty.nix
    ./home/neteaseMusic.nix
    ./home/obsidian.nix
    ./home/qq.nix
    ./home/tmux/default.nix
    ./home/vscode.nix
    ./home/wechat.nix
    ./home/yazi.nix
    ./home/zed.nix
    ./home/zen.nix
    ./home/zotero.nix
  ];
in
{
  home-manager.sharedModules = homeProfiles;
}
