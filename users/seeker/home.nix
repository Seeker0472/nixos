{
  config,
  lib,
  ...
}:
{
  ####################################################
  #
  #   All Seeker's Home Manager Conf.
  #
  ####################################################

  # 用户名与用户目录
  home = {
    username = lib.mkDefault "seeker";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
    stateVersion = "24.05";
  };

  imports = [
    ../../modules/home/base.nix
    ./tools.nix
    ./git.nix
    ./config.nix
    ./ssh.nix
  ];

  home.file.".codex/AGENTS.md".text = ''
    # User-level Codex instructions

    This host is declaratively managed with Nix and Home Manager. The Nix
    configuration source of truth is `/home/seeker/nixos-config`.

    ## Missing tools and Nix

    When a command or tool is missing:

    - Do not search `/nix/store` to discover packages or executables.
    - Confirm that the command is unavailable, then use `nix search`,
      `nix repl`, and `nix eval` to identify and verify the Nix package
      attribute. Remember that an executable name and a package attribute
      can be different.
    - Use `nix run nixpkgs#<package> -- <args>` for a one-off command.
    - Use `nix shell nixpkgs#<package> ...` for a temporary shell with several
      tools. Use `nix develop` for a repository's declared development shell.
    - Do not change the declarative configuration merely to satisfy a
      one-off tool requirement.
    - Repeated user tools belong in `users/seeker/tools.nix` under
      `home.packages`.
    - Project-only development tools belong in `outputs/devshell.nix`.
      System or service dependencies belong in the relevant NixOS module.
    - Do not use `nix-env` or `nix profile install` for persistent tools
      managed by this configuration.

    After changing the Nix configuration, run the relevant flake checks and
    dry-builds. Follow repository-specific maintenance instructions before
    deploying any system change.
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
