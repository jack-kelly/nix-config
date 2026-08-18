{ pkgs, ... }:
{
  # Jetson Linux (L4T) flash dependencies, used by baja-yocto's
  # prog-tarball-to-target.sh and initrd-flash. Installed system-wide (not
  # just in baja-yocto's flake devShell) because both scripts require sudo,
  # which resets PATH to its own secure_path — only /run/current-system/sw/bin
  # (systemPackages) and similar are on it, not a devShell's store paths.
  environment.systemPackages = with pkgs; [
    abootimg
    binutils
    bmaptool
    cpio
    dtc
    dosfstools
    gptfdisk # sgdisk
    lbzip2
    libxml2
    lz4
    netcat-openbsd
    openssl
    parted # partprobe, used by initrd-flash
    (python3.withPackages (p: [ p.pyyaml ]))
    rsync
    sshpass
    whois
    xmlstarlet
    zstd
  ];

  # NFS-root boot support for the target (meta-baja's DISTRO_FEATURES
  # includes "nfs").
  services.nfs.server.enable = true;

  # Run target/aarch64 binaries directly on the host during flashing/dev.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # initrd-flash uses udisksctl to mount/unmount the in-target USB
  # storage device exposed during programming. Needs the daemon (this
  # option) and the CLI (provided by the same package).
  services.udisks2.enable = true;

  # Prevent desktop file managers from auto-mounting the in-target USB
  # block device while initrd-flash is using it.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="block", ENV{UDISKS_AUTO}="0"
  '';
}
