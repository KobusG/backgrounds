{ config, ... }:
{
  imports = [
    ./hardware.nix
    ../../profiles/macos.nix
    ../../config/desktop/macos/applications.nix
  ];

  config = {
    networking.hostName = "crazy-diamond";

    primary-user = {
      name = "kobus";
      git.user.name = config.primary-user.name;
      git.user.email = "git@kobus.com";
      user.home = /Users/kobus;
    };

    # TODO: Abstract this out.
    services.nix-daemon.enable = true;
    users.nix.configureBuildUsers = true;

    nix.distributedBuilds = true;
    nix.buildMachines = [
      {
        hostName = "10.0.1.150";
        sshUser = "kobus";
        sshKey = "/Users/kobus/.ssh/id_enigma";
        systems = [ "x86_64-linux" ];
        maxJobs = 2;
      }
    ];

    ###########################################################################
    # Used for backwards compatibility, please read the changelog before
    # changing.
    #
    # $ darwin-rebuild changelog
    system.stateVersion = 4;
  };
}
