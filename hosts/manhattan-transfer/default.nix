{ config, ... }:
{
  imports = [
    ./hardware.nix
    ../../profiles/macos.nix
    # ../../modules/system/primary-user/macos.nix
    # ../../config/system/nix/macos.nix
  ];

  config = {
    networking.hostName = "manhattan-transfer";

    primary-user = {
      name = "kobus";
      git.user.name = config.primary-user.name;
      git.user.email = "git@kobus.com";
      user.home = /Users/kobus;
    };

    homebrew = {
      brewPrefix = "/opt/homebrew/bin";
      casks = [
        "firefox" # A good web browser.
        "iterm2" # A better terminal emulator.
        "keepassxc" # An alternative password manager.
        "slack" # Business chat.
      ];
    };

    # TODO: Abstract this out.
    services.nix-daemon.enable = true;
    users.nix.configureBuildUsers = true;

    ###########################################################################
    # Used for backwards compatibility, please read the changelog before
    # changing.
    #
    # $ darwin-rebuild changelog
    system.stateVersion = 4;
  };
}
