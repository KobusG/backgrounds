#####################################
# Misc. NixOS desktop applications. #
#####################################
{ pkgs, unstable, ... }:

{

  services.dropbox.enable
  primary-user = {
    home-manager.home.packages = (with pkgs ; [
      # slack
      xclip # Clipboard selection a la `cat foo | xclip -selection clipboard`
      unstable.vscode
      etcher
      arc-kde-theme
      google-chrome
    ]);
  };
}
