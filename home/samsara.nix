{ ... }:
{
  imports = [
    ./global
    ./bundles/i3
    ./bundles/nvidia
    ./bundles/work
    # Not the full ./bundles/desktop (discord/obsidian/spotify/signal/firefox) —
    # this is a compute tower. Keep only the alacritty config, since i3, rofi and
    # stylix all reference "alacritty" as the terminal; without it Mod+Return is a
    # no-op. Fonts come from stylix (./bundles/i3/stylix.nix), not the bundle.
    ./bundles/desktop/alacritty.nix
    # No ./bundles/i3/autorandr.nix: that profile set is built around an eDP-1
    # laptop panel (it requires local.autorandr.eDP1). samsara is a desktop
    # tower with monitors on the A400 — use arandr/nvidia-settings for layout.
  ];

  # Compute tower: no chat/music apps autostarted. i3 is launched on demand via
  # `startx`; leave local.i3.startupApps at its default (empty).
}
