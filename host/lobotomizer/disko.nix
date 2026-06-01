{ ... }:
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          uuid = "594144da-f0bd-4a6d-9413-c5e74a466ca3";
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
          size = "896.7G";
          uuid = "46060076-dbe3-4978-998b-688901410deb";
          content = {
            type = "luks";
            name = "luks-4c9bf3ca-ac45-4e52-8676-67cd8b7f0fb5";
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
          uuid = "3f2c1af2-f055-4bf6-9d71-e050b2a3e360";
          content = {
            type = "luks";
            name = "luks-94984eb9-c989-424d-b636-a57f7086e0f7";
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
