{ pkgs, ... }:
let
plugins = import ./vscode_plugin.nix;
in
{
  #jq for script
  home.packages = with pkgs;[jq];
  # home.packages = with pkgs;[vscode];
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    # mutableExtensionsDir = false;
    # settings
    userSettings = {
      "files.autoSave" = "onFocusChange";
      # git
      "git.suggestSmartCommit" = false;
      "git.autofetch" = true;
      
      "files.watcherExclude" = {
        "**/.bloop" = true;
        "**/.metals" = true;
        "**/.ammonite" = true;
      };
      "C_Cpp.intelliSenseEngine" = "disabled";
      "digital-ide.welcome.show" = false;
      "metals.inlayHints.hintsInPatternMatch.enable" = true;
      # markdown
      "markdown.marp.enableHtml" = true;
      "markdown.marp.exportType" = "html";
      "markdown-pdf.executablePath" = "chromium";

      "workbench.colorTheme" = "Night Owl"; # TODO
      # vims
      # "vim.autoSwitchInputMethod.enable" = true;
      # "vim.autoSwitchInputMethod.defaultIM" = "2";
      # "vim.autoSwitchInputMethod.obtainIMCmd" = "fcitx5-remote";
      # "vim.autoSwitchInputMethod.switchIMCmd" = "fcitx5-remote -t 2";
      # "vim.useSystemClipboard"= true;

      };
    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace plugins.extensions;    
    };

  }
