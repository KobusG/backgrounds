{ config, inputs, lib, pkgs, unstable, ... }:

{
  imports = [
    # NixOS desktop configuration profile.
    ../../profiles/nixos/desktop.nix
    # Machine-specific hardware configuration.
    ./hardware.nix
  ];

  #############################################################################
  # Machine-specific global packages.
  #############################################################################
  environment.systemPackages = with pkgs; [
    # NOTE: Something's messed up with the Blue Yeti Nano, so its gain needs
    # to be manually adjusted.
    #
    # TODO: Look into 'pipewire' as an alternative to 'pulseaudio' which might
    # help improve the overall audio situation...
    #
    # ...or just ditch Linux and switch back to macOS, the desktop experience
    # is absolutely fucking miserable.
    pavucontrol
  ];

  #############################################################################
  # System user configuration.
  #############################################################################
  # TODO: All deploys should use immutable users where possible, so this
  # should be a part of the base nixos config module.
  users.mutableUsers = false;

  # FIXME: Change this to a different password from the `primary-user`.
  # TODO: Source this from a file in '/secrets'.
  users.users.root.initialHashedPassword =
    "$6$uOrKO2alBMBCWDah$4LLdzhDQFKyOgyqXrmxich9HAj051kg/CwyzFniYcA9YWAdxkPMaqO/FOqvadF0LMeECLQhapmuW3N85GlCfX1";

  #############################################################################
  # Primary user configuration.
  #############################################################################
  primary-user = {
    name = "kobus";
    git.user.name = config.primary-user.name;
    git.user.email = "git@kobus.com";

    # FIXME: Change this to a different password from the root user.
    # TODO: Source this from a file in '/secrets'.
    initialHashedPassword =
      "$6$uOrKO2alBMBCWDah$4LLdzhDQFKyOgyqXrmxich9HAj051kg/CwyzFniYcA9YWAdxkPMaqO/FOqvadF0LMeECLQhapmuW3N85GlCfX1";
    home-manager.home.packages = with pkgs; [
      docker-compose # Hasura development tooling.
    ];
  };

  #############################################################################
  # Global persistence.
  #############################################################################

  environment.etc = {
    # TODO: Check if this can use the `home-manager` XDG home stuff.
    "nixos".source = "${config.primary-user.home.directory}/.config/dotfiles";
    # "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections/";


  };

  systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    "L /var/lib/docker    - - - - /persist/var/lib/docker"
  ];

  #############################################################################
  # Machine identification.
  #############################################################################
  # TODO: Source the following two values from files in '/persist'.
  # networking.hostId = "yoga"; # Required by ZFS.
  # environment.etc."machine-id".text = "0aaab60e7c4a49d49c953e4972dbe443";

  #############################################################################
  # Networking.
  #############################################################################
  networking = {
    hostName = "yoga";

    # firewall.enable = true;
    interfaces = {
      wlp1s0.useDHCP = true;
    };
    networkmanager.enable = true;

  };

  #############################################################################
  # System.
  #############################################################################
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  #
  # It‘s perfectly fine and recommended to leave this value at the release
  # version of the first install of this system.
  #
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11";
}
