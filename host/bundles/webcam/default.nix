{ config, pkgs, ... }:
{
  boot = {
    # uvcvideo drives generic USB webcams. It also covers the Pixel's built-in
    # USB webcam mode (Settings -> Connected devices -> USB -> Webcam), which
    # enumerates the phone as a plain UVC gadget — no host-side software.
    # The module autoloads on hotplug; listing it makes the dependency explicit.
    #
    # v4l2loopback provides /dev/video10 as a virtual camera, for feeding a
    # source that isn't a real capture device (scrcpy over wifi, OBS) into apps
    # that only speak v4l2. Drop it from kernelModules to load on demand
    # instead; the cost is a phantom "Virtual Camera" in every app's device list.
    kernelModules = [
      "uvcvideo"
      "v4l2loopback"
    ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    # exclusive_caps=1 makes the loopback device advertise itself as capture-only
    # until something writes to it, which is what Chrome/Firefox/Zoom require to
    # list it at all.
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=10 card_label="Virtual Camera" exclusive_caps=1
    '';
  };

  environment.systemPackages = with pkgs; [
    # v4l2-ctl --list-devices / --all for inspecting and tuning capture devices
    v4l-utils
    # Wireless/rear-camera path for the Pixel; the nixpkgs build already wraps
    # adb on PATH. Phone access over USB comes from systemd's uaccess rules, so
    # no android-udev-rules (removed from nixpkgs) is needed.
    scrcpy
  ];
}
