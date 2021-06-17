# System configuration.

{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix

    ../../modules/services/dns/dnscrypt-proxy.nix
    ../../modules/services/dns/podman-pihole.nix
    ../../modules/services/media/hardware-acceleration.nix
    ../../modules/services/media/plex.nix
  ];

  #############################################################################
  # PACKAGE MANAGEMENT
  #############################################################################

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bind.dnsutils
    ripgrep
    wireguard
    vim
    zfs
  ];

  #############################################################################
  # MEDIA
  #############################################################################

  # TODO: Remove, or abstract out into its own service definition.
  #
  # let
  #   jellyfin = pkgs.jellyfin.overrideAttrs (oldAttrs: rec {
  #     version = "10.6.4";
  #     src = builtins.fetchurl {
  #       url = "https://repo.jellyfin.org/releases/server/portable/versions/stable/combined/${version}/jellyfin_${version}.tar.gz";
  #       sha256 = "OqN070aUKPk0dXAy8R/lKUnSWen+si/AJ6tkYh5ibqo=";
  #     };
  #   });
  # in
  #
  #
  # systemd.packages = [ jellyfin ];

  # systemd.services.jellyfin.serviceConfig = rec {
  #   User = "plexuser";
  #   Group = "plexgroup";
  #   CacheDirectory = "jellyfin";
  #   StateDirectory = "jellyfin";
  #   ExecStart = "${jellyfin}/bin/jellyfin --datadir '/var/lib/${StateDirectory}' --cachedir '/var/cache/${CacheDirectory}'";
  # };

  #############################################################################
  # SYSTEM PERSISTENCE
  #############################################################################

  environment.etc."machine-id".text = "4b632b7bbd1940ecaceab8ecc74be662";

  # Persistent logs that should _NOT_ be tracked within ZFS snapshots.
  #
  # XXX: Maybe place this closer to the ZFS filesystem declaration.
  environment.persistence."/state/logs" = {
    directories = [ "/var/log" ];
  };

  # Misc. global NixOS persistence (e.g. system configuration)
  environment.persistence."/state/nixos" = {
    directories = [ "/etc/nixos" ];
  };

  #############################################################################
  # USER SETTINGS
  #############################################################################

  # XXX: Would it be better to explicitly add `NOPASSWD` for my username in 
  # `security.sudo.extraRules`?
  security.sudo.wheelNeedsPassword = false;

  users = {
    mutableUsers = false;
    users.root.initialHashedPassword = "$6$W19HRt8s/zk$BlnuJqAugFV7Pb2kNEM7qFnUUJrfDl6lHHRbuftE8Dr4/wPgSRyws5SZHFl9jefrxn1yqyjzlhPQptlP0vm6d0";

    users.jkachmar = {
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      initialHashedPassword = "$6$0LBk.zAnK$QjEiGbc9G1N49MtOXWEpvYooII/8zY7a8t92hZiTu0xx58P7ORf/WzLqiTF7usj9pgjveBJHSSvXPQvI7H/Lx/";
      uid = 1000;

      # TODO: Investigate using keyFiles instead.
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrZAwektbexTFUtSn0vuCHP6lvTvA/jdOb+SF5TD9VA me@jkachmar.com"
      ];
    };
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.jkachmar = { pkgs, ... }: {
    imports = [ "${inputs.impermanence}/home-manager.nix" ];
    programs.home-manager.enable = true;
    programs.git.enable = true;
    programs.ssh = {
      enable = true;
      userKnownHostsFile = "/secrets/ssh/jkachmar/known_hosts";
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = ["/secrets/ssh/jkachmar/id_github"];
        };
      };
    };

    xdg = {
      enable = true;
      configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";
      configFile."nix/nix.conf".text = "experimental-features = nix-command flakes ca-references";
    };

    home.persistence."/state/jkachmar/home/misc" = {
      files = [ ".bash_history" ];
      allowOther = true;
    };
  };

  #############################################################################
  # BOOT
  #############################################################################
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  #############################################################################
  # NETWORKING
  #############################################################################

  networking.hostId = "8425e349"; # Required by ZFS.
  networking.hostName = "enigma";

  # Network interface settings
  #
  # NOTE: The global `useDHCP` flag is deprecated; per-interface `useDHCP`
  # will be mandatory in the future, and so it is set here.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Firewall settings.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # TODO: Document why this is necessary (JellyFin?).
      8096
    ];
    allowedUDPPorts = [
      # Wireguard
      51820
    ];

    # TODO: Finish setting up wireguard & extract it outta here.
    # trustedInterfaces = [ "wg1" ];
  };

  # TODO: Configure specific fail2ban rules.
  services.fail2ban = {
    enable = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;

    challengeResponseAuthentication = false;
    permitRootLogin = "no";
    passwordAuthentication = false;

    hostKeys = [
      {
        path = "/secrets/ssh/host/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/secrets/ssh/host/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  #############################################################################
  # SYSTEM SETTINGS
  #############################################################################

  nix.trustedUsers = [ "root" "jkachmar" ];

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes ca-references
  '';
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  #############################################################################
  # MISC.
  #############################################################################

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
