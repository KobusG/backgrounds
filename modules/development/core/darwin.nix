{ pkgs, ... }:

let
  gcoreutils = pkgs.coreutils.override {
    singleBinary = false;
    withPrefix = true;
  };
in

{
  ###############################################################################
  # System-level configuration.
  environment.systemPackages = with pkgs; [ gcoreutils ];

  programs = {
    bash.enable = true;
    fish.enable = true;
    zsh.enable = true;
  };

  ###############################################################################
  # User-level configuration.
  primary-user.home-manager = {
    home.packages = with pkgs; [
      coreutils # lol, macOS (BSD) coreutils are broken somehow
      # emacs-plus # lmao cannot believe I wasted my time with this...
      emacsMacport
      findutils
      lorri
    ];

    # Fixes a bug where fish shell doesn't properly set up the nix path on macOS.
    programs.fish.shellInit = ''
      for p in /run/current-system/sw/bin ~/.nix-profile/bin
        if not contains $p $fish_user_paths
          set -g fish_user_paths $p $fish_user_paths
        end
      end
    '';
  };
}
