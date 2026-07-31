{ ... }:
{
  # Mirrors the existing encrypted install (adopted, not reformatted): partition
  # UUIDs and LUKS mapper names match the disk, so nixos-rebuild switch declares
  # the same mounts. Sizes are cosmetic unless the disk is ever reformatted.
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          uuid = "df0f6974-901c-4297-9d3e-a122a69b61f0";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "fmask=0077"
              "dmask=0077"
            ];
          };
        };
        luks-root = {
          size = "1.75T";
          uuid = "967b94ce-8e5c-45bc-94e5-9012104ba1bb";
          content = {
            type = "luks";
            name = "luks-3366a872-4d46-4028-b0cd-d26c3ab1c6f0";
            settings.allowDiscards = true;
            passwordFile = "/tmp/luks-password";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
        luks-swap = {
          size = "100%";
          uuid = "865ea43c-fc47-441b-b85d-9e838e97eddb";
          content = {
            type = "luks";
            name = "luks-e338ce4a-0a62-465f-b972-d3f195eb7b13";
            settings.allowDiscards = true;
            passwordFile = "/tmp/luks-password";
            content = {
              type = "swap";
            };
          };
        };
      };
    };
  };
}
