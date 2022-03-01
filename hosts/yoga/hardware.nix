{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    kernel.sysctl."vm.swappiness" = 1;
    kernelModules = [ "kvm-intel" "sg" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "btrfs" ];

    initrd = {
      # FIXME: Comment explaining why these modules were enabled.
      kernelModules = [
        "dm-snapshot"
        "nls_cp437"
        "nls_iso8859_1"
      ];
      availableKernelModules = [
        "sdhci_pci"
        "ahci"
        "nvme"
        "sd_mod"
        "sr_mod"
        "usbhid"
        "usb_storage"
        "xhci_pci"
      ];
    };

    ###########################################################################
    # Encrypted volume management.
    ###########################################################################
    # preLVMTempMount."/key" = {
    #   device = "/dev/disk/by-label/secure";
    #   fsType = "vfat";
    # };

    # initrd.luks.devices = {
    #   "crypt" = {
    #     device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC37730N-part1";
    #     header = "/key/yoga/crypt/header";
    #     keyFile = "/key/yoga/crypt/keyfile";
    #     preLVM = true;
    #   };

    #   "cryptswap" = {
    #     device = "/dev/disk/by-id/nvme-ADATA_SX8200PNP_2J2220006023-part3";
    #     header = "/key/yoga/cryptswap/header";
    #     keyFile = "/key/yoga/cryptswap/keyfile";
    #     preLVM = true;
    #   };
    # };
  };

  #############################################################################
  # Filesystems.
  #############################################################################
  # fileSystems = {
  #   # Boot partition.
  #   "/boot" = {
  #     device = "/dev/disk/by-uuid/663E-74F0";
  #     fsType = "vfat";
  #   };

  #   # Ephermeral root partition.
  #   "/" = {
  #     device = "none";
  #     fsType = "tmpfs";
  #     options = [ "defaults" "size=4G" "mode=755" ];
  #   };

  #   # Nix store.
  #   "/nix" = {
  #     device = "yoga/nix";
  #     fsType = "zfs";
  #   };

  #   # [OLD] Persistent state.
  #   "/state" = {
  #     device = "yoga/state";
  #     fsType = "zfs";
  #     neededForBoot = true;
  #   };

  #   # [NEW] Persistent '/home' state.
  #   "/home" = {
  #     device = "yoga/persist/home";
  #     fsType = "zfs";
  #   };

  #   # [NEW] Persistent global state.
  #   "/persist" = {
  #     device = "yoga/persist/root";
  #     fsType = "zfs";
  #   };

  #   # [NEW] systemd-logging.
  #   #
  #   # Symlinking this with systemd-tmpfiles won't work since there's already
  #   # an entry for '/var/log' present by default.
  #   "/var/log" = {
  #     device = "yoga/persist/systemd-logs";
  #     fsType = "zfs";
  #     neededForBoot = true;
  #   };

  #   # systemd temporary files; sometimes we need a bit more temporary space
  #   # than a 4G RAMDISK allows.
  #   #
  #   # NOTE: Ensure that the aging parameters are set properly so that this
  #   # cleans up after itself.
  #   #
  #   # Symlinking this with systemd-tmpfiles won't work since there's already
  #   # an entry for '/var/tmp' present by default.
  #   "/var/tmp" = {
  #     device = "yoga/persist/systemd-tmp";
  #     fsType = "zfs";
  #     neededForBoot = false;
  #   };

  #   # [NEW] Local secret storage; sometimes needed for boot.
  #   "/secrets" = {
  #     device = "yoga/persist/secrets";
  #     fsType = "zfs";
  #     neededForBoot = true;
  #   };
  # };

  # services.zfs = {
  #   trim.enable = true;
  #   autoScrub.enable = true;
  #   autoSnapshot = {
  #     enable = true;
  #     flags = "-k -p --utc";
  #   };
  # };

  # swapDevices = [{ device = "/dev/mapper/cryptswap"; }];


  fileSystems."/" =
    { device = "/dev/sda5";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };

  fileSystems."/home" =
    { device = "/dev/sda5";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" "noatime" ];
    };

  fileSystems."/log" =
    { device = "/dev/sda5";
      fsType = "btrfs";
      options = [ "subvol=log" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/persist" =
    { device = "/dev/sda5";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/nix" =
    { device = "/dev/sda5";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/sda7";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/sda6"; }
    ];





  #############################################################################
  # NVIDIA
  #############################################################################
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  # services.xserver.videoDrivers = [ "nvidia" ];

  # TODO: Check with others on what makes for good tuning here...
  #
  # For now:
  #   - 4x maxJobs = up to 4 derivations may be built in parallel
  #   - 3x buildCores = each derivation will be given 3 cores to work with
  nix = {
    buildCores = lib.mkDefault 3;
    maxJobs = lib.mkDefault 4;
  };

  #############################################################################
  # Misc. other hardware settings (microcode updates, DPI, etc.)
  #############################################################################
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    # cpu.amd.updateMicrocode = true;
    video.hidpi.enable = lib.mkDefault true;
  };
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  services.xserver.dpi = 144;

}
