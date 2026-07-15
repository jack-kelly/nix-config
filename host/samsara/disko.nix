{ ... }:
{
  disko.devices.disk.main = {
    type = "disk";
    # PCIe5 NVMe root. Confirm the device path on the machine (`lsblk`) before
    # running disko — it may enumerate as nvme1n1 if other NVMe drives are present.
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          uuid = "ccc9d4a7-6ce4-4d52-aa7e-8848f19f9323";
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
          # 2TB drive: leave the tail for swap (64G) below.
          size = "1.85T";
          uuid = "f1b034ff-96ac-4a36-98e7-2d5c0621dd5d";
          content = {
            type = "luks";
            name = "luks-9d4d6b15-d4ea-425f-946a-1d6bb20402b6";
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
          uuid = "3d24a604-ec86-423e-b941-097c9f92df6f";
          content = {
            type = "luks";
            name = "luks-cbdfed52-38bc-43e0-b44d-c542439eef8b";
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
