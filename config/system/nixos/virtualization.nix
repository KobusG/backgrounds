#######################################
# NixOS virtualization configuration. #
#######################################
{ config, pkgs, ... }:

{
  # virtualisation.docker = {
  #   enable = true;
  #   enableNvidia = true;
  # };

  # # TODO: Abstract this out to the `primary-user` config module.
  # users.users.kobus.extraGroups = [ "docker" ];



  # Use Podman to run OCI containers.
  #
  # TODO: Factor OCI container backend configuration out to a more generic
  # module if/when more OCI-based services are added.
  virtualisation = {
    containers = {
      enable = true;
      storage.settings.storage = {
        # driver = "zfs";
        graphroot = "/persist/podman/containers";
        runroot = "/run/containers/storage";
      };
    };

    podman = {
      enable = true;
      dockerCompat = true;

      # Only needed for zfs systems
      extraPackages = [ pkgs.zfs ];
    };

    oci-containers.backend = "podman";
  };

}
