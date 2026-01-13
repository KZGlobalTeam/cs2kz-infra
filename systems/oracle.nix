{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../modules/base.nix
    ../modules/cs2kz-api.nix
    # ../modules/flarum.nix
  ];
  boot = {
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
      configurationLimit = 1;
    };
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "xen_blkfront"
      ];
      kernelModules = [ "nvme" ];
    };
  };
  fileSystems = {
    "/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/1B9E-BDB1";
      fsType = "vfat";
    };
  };
  networking = {
    hostName = "cs2kz-api";
    firewall.interfaces = {
      "enp0s6" = {
        allowedTCPPorts = [ 22 80 443 ];
      };
    };
  };
}
