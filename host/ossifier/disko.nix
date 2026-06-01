{ ... }:
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          uuid = "6a377b89-1d79-4a5f-bc3f-93f4152e65f4";
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
          size = "1828G";
          uuid = "9966ecc5-e210-4d79-a14f-6310be3973a3";
          content = {
            type = "luks";
            name = "luks-4e83cb04-c239-4463-b55c-a3814beeaa65";
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
          uuid = "583edd3f-9e25-4887-bfa2-64339cbec4b0";
          content = {
            type = "luks";
            name = "luks-3ef56867-64ff-4094-976e-2188ecbf4057";
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
