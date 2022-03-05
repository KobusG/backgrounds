##############################################
# NixOS K desktop environment configuration. #
##############################################
{ pkgs, ... }:
{
  services.xserver = {
    # Use KDE as the desktop environment.
    desktopManager.plasma5.enable = true;
    displayManager.sddm.enable = true;
  };

  primary-user.home-manager.home.packages = with pkgs.plasma5Packages.kdeApplications; [
    ark
    kate
    kcalc
    pkgs.kdeconnect
    pkgs.kdeplasma-addons
    spectacle
  ];

  # primary-user.home-manager = {
  #   services.random-background = {
  #     enable = true;
  #     imageDirectory = "/persist/etc/nixos/backgrounds";
  #     interval = "5m";
  #   };
  # };

  # needed for store VSCode auth token
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  # TODO: Abstract this out to the `primary-user` configuration.
  security.pam.services.kobus.enableKwallet = true;
}
