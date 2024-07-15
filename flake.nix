{
  # ================================================================ #
  # =                           WELCOME!                           = #
  # ================================================================ #

  description = "jack-kelly's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    prism = {
      url = "github:IogaMaster/prism";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {...} @ inputs: let
    # super simple boilerplate-reducing
    # lib with a bunch of functions
    myLib = import ./lib/default.nix {inherit inputs;};
  in
    with myLib; {
      nixosConfigurations = {
        # ===================== NixOS Configurations ===================== #

        necropanther = mkSystem ./hosts/necropanther/configuration.nix;
      };

      homeConfigurations = {
        # ================ Maintained home configurations ================ #

        necropanther = mkHome "x86_64-linux" ./hosts/necropanther/home.nix;
      };

      homeManagerModules.default = ./home;
      nixosModules.default = ./nixos;
    };
}
