{
  description = "My programs and configurations";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { nixpkgs, home-manager, ... }@inputs: {
    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#hostname'
    homeConfigurations = {
      "wungus" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          config_id = "wungus";
        };
        modules = [ ./home/wungus.nix ];
      };
      "hopoo" = home-manager.lib.homeManagerConfiguration {
	pkgs = nixpkgs.legacyPackages.x86_64-linux;
	extraSpecialArgs = {
	  config_id = "hopoo";
	};
	modules = [ ./home/hopoo.nix ];
      };
    };

    nixosConfigurations = {
      "hopoo" = nixpkgs.lib.nixosSystem {
        system = "x86_64";
        modules = [
	  ./host/hopoo/configuration.nix
	  ./host/hopoo/hardware-configuration.nix
	];
      };
    };

    inherit home-manager;
    inherit (home-manager) packages;
  };

}
