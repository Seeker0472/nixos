{ pkgs, ... }:
let
  code-runner = {
    name = "code-runner";
    publisher = "formulahendry";
    version = "0.12.2";
    sha256 = "0i5i0fpnf90pfjrw86cqbgsy4b7vb6bqcw9y2wh9qz6hgpm4m3jc";
  };
  c_cpp-pack = {
    name = "cpptools-extension-pack";
    publisher = "ms-vscode";
    version = "1.3.0";
    sha256 = "11fk26siccnfxhbb92z6r20mfbl9b3hhp5zsvpn2jmh24vn96x5c";
  };
  remote-dev = {
    name = "vscode-remote-extensionpack";
    publisher = "ms-vscode-remote";
    version = "0.26.0";
    sha256 = "0xjld7p1zg9zybcw47xzrikgyc3hp9lfk6vbrm0syba8n90k8jk1";
  };
  docker = {
    name = "vscode-docker";
    publisher = "ms-azuretools";
    version = "1.29.3";
    sha256 = "1j35yr8f0bqzv6qryw0krbfigfna94b519gnfy46sr1licb6li6g";
  };
  python = {
    name = "python";
    publisher = "ms-python";
    version = "2024.5.11021008";
    sha256 = "11mnnbdl7cqr18s2cvv2132rrq1f5zslnihp5i2jpa2awjak8wjj";
  };
  makefile = {
    name = "makefile-tools";
    publisher = "ms-vscode";
    version = "0.12.10";
    sha256 = "15ngmjxzaa66v3nrzwjiynav9r8rwayql6hzxlvhl25avm08brhs";
  };
  verilog-support = {
    name = "fpga-support";
    publisher = "sterben";
    version = "0.3.3";
    sha256 = "1al7zi802rxawly2pilg3dzk9zjbzcvdgj2v4mhmm129jqf3qsc7";
  };
  linkerscript = {
    name = "linkerscript";
    publisher = "ZixuanWang";
    version = "1.0.4";
    sha256 = "0mfna6xypzfwsrmfzx898pc76ddfn4n8yr8l4d8gbhcyqyj5y3zp";
  };
in
{
  # home.packages = with pkgs;[vscode];
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
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

      "workbench.colorTheme" = "Night Owl";
      # vims
      "vim.autoSwitchInputMethod.enable" = true;
      "vim.autoSwitchInputMethod.defaultIM" = "2";
      "vim.autoSwitchInputMethod.obtainIMCmd" = "fcitx5-remote";
      "vim.autoSwitchInputMethod.switchIMCmd" = "fcitx5-remote -t 2";
      "vim.useSystemClipboard"= true;

      };
      # extensions
      extensions = with pkgs.vscode-extensions; [
        scalameta.metals
        vscodevim.vim
        mads-hartmann.bash-ide-vscode
        llvm-vs-code-extensions.vscode-clangd
        mkhl.direnv
        # yzane.markdown-pdf
        yzhang.markdown-all-in-one
        marp-team.marp-vscode
        jnoortheen.nix-ide
        mhutchie.git-graph
        # formulahendry.code-runner
        # dracula-theme.theme-dracula
        # yzhang.markdown-all-in-one
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        code-runner
        c_cpp-pack
        remote-dev
        docker
        python
        makefile
        verilog-support
        linkerscript
      ];
    };

  }
