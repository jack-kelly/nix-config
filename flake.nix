{
  # ================================================================ #
  # =                           WELCOME!                           = #
  # ================================================================ #

  description = "jack-kelly's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    xremap-flake.url = "github:xremap/nix-flake";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    prism = {
      url = "github:IogaMaster/prism";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixpkgs-wivrn = {
      url = "github:nixos/nixpkgs/efdeeae66101269fdcb3624ed315f6cfbf08ca95";
      # url = "github:nixos/nixpkgs/19e0a58bcc6f1df16c48cdbac7d159d0e6fd9a00";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    ags.url = "github:Aylur/ags";

    persist-retro.url = "github:Geometer1729/persist-retro";
  };

  outputs = {...} @ inputs: let
    # super simple boilerplate-reducing
    # lib with a bunch of functions
    myLib = import ./myLib/default.nix {inherit inputs;};
  in
    with myLib; {
      nixosConfigurations = {
        # ===================== NixOS Configurations ===================== #

        necropanther = mkSystem ./hosts/necropanther/configuration.nix;
      };

      homeConfigurations = {
        # ================ Maintained home configurations ================ #

        "necropanther" = mkHome "x86_64-linux" ./hosts/necropanther/home.nix;
      };

      homeManagerModules.default = ./homeManagerModules;
      nixosModules.default = ./nixosModules;
    };
}
