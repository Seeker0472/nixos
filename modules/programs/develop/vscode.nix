{ pkgs, ... }:
let
  plugins = import ./vscode_plugin.nix;
in
{
  #jq for script
  home.packages = with pkgs;[ jq ];
  # home.packages = with pkgs;[vscode];
  programs.vscode = {
  "extensions.autoCheckUpdates": false,
  "files.autoSave": "onFocusChange",
  "files.watcherExclude": {
    "**/.ammonite": true,
    "**/.bloop": true,
    "**/.metals": true
  },
  "git.autofetch": true,
  "git.suggestSmartCommit": false,
  "markdown-pdf.executablePath": "chromium",
  "markdown.marp.enableHtml": true,
  "markdown.marp.exportType": "html",
  "update.mode": "none",
  "workbench.colorTheme": "Monokai Pro (Filter Octagon)",
  "vscode-neovim.neovimInitVimPaths.linux": "/home/seeker/.config/nvim/init.lua",
  "vscode-neovim.compositeKeys": {
    "jk": {
      "command": "vscode-neovim.escape",
    },
  },
  "extensions.experimental.affinity": {
    "asvetliakov.vscode-neovim": 1
  },
  "workbench.iconTheme": "Monokai Pro (Filter Octagon) Monochrome Icons",
  "git.confirmSync": false,
  "vscode_custom_css.imports": [
   "file:///home/seeker/.config/Code/User/custom.css" 
  ],
  "monokaiPro.fileIconsMonochrome": true,
  "C_Cpp.intelliSenseEngine": "disabled",
  "makefile.configureOnOpen": true,
  "workbench.editor.tabActionCloseVisibility": fals

    };
    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace plugins.extensions;
  };

}
