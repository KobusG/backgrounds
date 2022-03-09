{ config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;
  inherit (lib) optionalAttrs optionalString;
  username = config.primary-user.name;
in

{
  primary-user.home-manager.programs.ssh = {
    enable = true;

    # userKnownHostsFile = "~/.ssh/known_hosts";

    # NOTE: lol this is awful, there's gotta be a better way to handle these.
    matchBlocks = {
      # "10.0.1.150" = {
      #   hostname = "10.0.1.150";
      #   user = "kobus";
      # } // optionalAttrs isDarwin {
      #   identityFile = [ "~/.ssh/id_enigma" ];
      # } // optionalAttrs isLinux {
      #   identityFile = [ "/secrets/openssh/client/${username}/id_enigma" ];
      # };

      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/github_ed25519";
      };

      # "gitlab.com" = {
      #   hostname = "gitlab.com";
      #   user = "git";
      # } // optionalAttrs isDarwin {
      #   identityFile = [ "~/.ssh/id_gitlab" ];
      # } // optionalAttrs isLinux { };

      # "build.stackage.org" = {
      #   user = "curators";
      #   hostname = "build.stackage.org";
      # } // optionalAttrs isDarwin {
      #   identityFile = [ "~/.ssh/id_rsa_stackage" ];
      # } // optionalAttrs isLinux { };
    };
  };
}
