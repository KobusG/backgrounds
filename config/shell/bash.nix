###########################################
# OS-agnostic `bash` shell configuration. #
###########################################
{ config, ... }:
{
  primary-user.home-manager.programs.bash.enable = true;
  primary-user.home-manager.programs.readline = {
    enable = true;
    extraConfig = ''
"\e[A": history-search-backward
"\e[B": history-search-forward
"\e[C": forward-char
"\e[D": backward-char
'';
  };
}
