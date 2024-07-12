{pkgs, ...}: {
  hardware.uinput.enable = true;
  users.groups.uinput.members = ["jack"];
  users.groups.input.members = ["jack"];
}
