{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    kernel.sysctl."vm.swappiness" = 1;
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "btrfs" ];

    initrd = {
      # FIXME: Comment explaining why these modules were enabled.
      kernelModules = [ "dm-snapshot" ];
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
  };

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
